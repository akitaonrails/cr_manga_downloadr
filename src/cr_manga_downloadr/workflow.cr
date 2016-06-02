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
        engine  = CrMangaDownloadr::Pages.new(@config.domain)
        channel = Channel(Array(String)).new
        batch.each do |link|
          spawn { channel.send(engine.fetch(link) as Array(String)) }
        end
        batch.size.times { pages = pages.concat(channel.receive) }
        puts "Pages links fetched so far: #{pages.try &.size}"
        channel.close
      end
      puts "Number of Pages: #{pages.try &.size}"
      pages
    end

    private def fetch_images(pages : Array(String))
      puts "Feching the Image URLs from each Page ..."
      images         = [] of Image
      pages.each_slice(@config.download_batch_size) do |batch|
        engine   = CrMangaDownloadr::PageImage.new(@config.domain)
        channel = Channel(Image).new
        batch.each do |link|
          spawn { channel.send(engine.fetch(link) as Image) }
        end
        batch.size.times { images << channel.receive }
        puts "Images links fetched so far: #{images.try &.size}"
        channel.close
      end
      puts "Number of Images: #{images.try &.size}"
      images
    end

    private def download_images(images : Array(Image))
      puts "Downloading each image ..."
      downloads         = [] of String
      images.each_slice(@config.download_batch_size) do |batch|
        channel = Channel(String).new
        batch.each do |image|
          spawn {
            image_file = File.join(@config.download_directory, image.filename)
            CrMangaDownloadr::ImageDownloader.new(image.host).fetch(image.path, image_file)
            channel.send image_file
          }
        end
        batch.size.times { downloads << channel.receive }
        channel.close
        puts "Images downloaded so far: #{downloads.try &.size}"
      end
      puts "Number of images downloaded: #{downloads.try &.size}"
      downloads
    end

    def run
      `mkdir -p #{@config.download_directory}`
      chapters = fetch_chapters
      if chapters
        pages = fetch_pages(chapters)
        if pages
          images = fetch_images(pages)
          if images
            downloads = download_images(images)
          end
        end
      end
    end
  end
end
