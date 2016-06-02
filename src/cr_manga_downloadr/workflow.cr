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
      reactor = Concurrency(String, String, Pages).new(@config)
      reactor.fetch(chapters) do |link, engine|
        engine.fetch(link) as Array(String)
      end
    end

    private def fetch_images(pages : Array(String))
      puts "Feching the Image URLs from each Page ..."
      reactor = Concurrency(String, Image, PageImage).new(@config)
      reactor.fetch(pages) do |link, engine|
        [ engine.fetch(link) as Image ]
      end
    end

    private def download_images(images : Array(Image))
      puts "Downloading each image ..."
      reactor = Concurrency(Image, String, ImageDownloader).new(@config)
      reactor.fetch(images) do |image, engine|
        image_file = File.join(@config.download_directory, image.filename)
        unless File.exists?(image_file)
          ImageDownloader.new(image.host).fetch(image.path, image_file)
        end
        [ image_file ]
      end
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
