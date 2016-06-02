module CrMangaDownloadr
  class Workflow
    def initialize(@config : Config); end

    private def fetch_chapters
      puts "Fetching chapters ..."
      chapters = CrMangaDownloadr::Chapters.new(@config.domain, @config.root_uri).fetch
      puts "Number of Chapters: #{chapters.try &.size}"
      chapters
    end

    private def fetch_pages(chapters : Array(String))
      puts "Fetching pages from all chapters ..."
      pages = [] of String
      chapters.each_slice(@config.download_batch_size) do |batch|
        engine  = Pages.new(@config.domain)
        channel = Pages.channel
        batch.each do |link|
          spawn { channel.send(engine.fetch(link) as Array(String)) }
        end
        batch.size.times { pages = pages.concat(channel.receive) }
        puts "Pages links fetched so far: #{pages.try &.size}"
        channel.close
      end
      pages
    end

    private def fetch_images(pages : Array(String))
      puts "Feching the Image URLs from each Page ..."
      images = [] of Image
      pages.each_slice(@config.download_batch_size) do |batch|
        engine   = PageImage.new(@config.domain)
        channel = PageImage.channel
        batch.each do |link|
          spawn { channel.send(engine.fetch(link) as Image) }
        end
        batch.size.times { images << channel.receive }
        puts "Images links fetched so far: #{images.try &.size}"
        channel.close
      end
      images
    end

    private def download_images(images : Array(Image))
      puts "Downloading each image ..."
      downloads = [] of String
      images.each_slice(@config.download_batch_size) do |batch|
        channel = ImageDownloader.channel
        batch.each do |image|
          spawn {
            image_file = File.join(@config.download_directory, image.filename)
            unless File.exists?(image_file)
              ImageDownloader.new(image.host).fetch(image.path, image_file)
            end
            channel.send image_file
          }
        end
        batch.size.times { downloads << channel.receive }
        channel.close
        puts "Images downloaded so far: #{downloads.try &.size}"
      end
      downloads
    end

    private def optimize_images
      puts "Running mogrify to convert all images down to Kindle supported size (600x800)"
      `mogrify -resize #{@config.image_dimensions} #{@config.download_directory}/*.jpg`
    end

    private def prepare_volumes(downloads : Array(String))
      manga_name = @config.download_directory.split("/").try &.last
      index = 1
      downloads.each_slice(@config.pages_per_volume) do |batch|
        volume_directory = "#{@config.download_directory}/#{manga_name}_#{index}"
        volume_file      = "#{volume_directory}.pdf"
        `mkdir -p #{volume_directory}`

        puts "Moving images to #{volume_directory} ..."
        batch.each do |file|
          destination_file = file.split("/").last
          `mv #{file} #{volume_directory}/#{destination_file}`
        end

        puts "Generating #{volume_file} ..."
        `convert #{volume_directory}/*.jpg #{volume_file}`

        index += 1
      end
    end

    def run
      # FIXME: didn't find Ruby's equivalent for FileUtils.mkdir_p
      `mkdir -p #{@config.download_directory}`
      chapters = fetch_chapters
      if chapters
        pages = fetch_pages(chapters)
        if pages
          images = fetch_images(pages)
          if images
            downloads = download_images(images)
            if downloads
              optimize_images
              prepare_volumes(downloads)
            end
          end
        end
      end
      puts "Done!"
    end
  end
end
