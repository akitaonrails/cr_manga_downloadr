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
      pages_engine  = CrMangaDownloadr::Pages.new(@config.domain)
      pages_channel = Channel(Array(String)).new
      pages         = [] of String
      chapters.each_slice(@config.download_batch_size) do |chapters_slice|
        chapters_slice.each do |chapter_link|
          spawn {
            links = pages_engine.fetch(chapter_link)
            pages_channel.send(links as Array(String))
          }
        end
        chapters_slice.size.times do
          pages = pages.concat(pages_channel.receive)
        end
        puts "Pages links fetched so far: #{pages.try &.size}"
      end
      puts "Number of Pages: #{pages.try &.size}"
      pages
    end

    private def fetch_images(pages : Array(String))
      puts "Feching the Image URLs from each Page ..."
      image_engine   = CrMangaDownloadr::PageImage.new(@config.domain)
      images_channel = Channel(Image).new
      images         = [] of Image
      pages.each_slice(@config.download_batch_size) do |pages_slice|
        pages_slice.each do |page_link|
          spawn {
            links = image_engine.fetch(page_link)
            images_channel.send(links as Image)
          }
        end
        pages_slice.size.times do
          images << images_channel.receive
        end
        puts "Images links fetched so far: #{images.try &.size}"
      end
      puts "Number of Images: #{images.try &.size}"
      images
    end

    private def download_images(images : Array(Image))
      puts "Downloading each image ..."
      downloads_channel = Channel(String).new
      downloads         = [] of String
      images.each_slice(@config.download_batch_size) do |images_slice|
        images_slice.each do |image|
          spawn {
            image_file = File.join(@config.download_directory, image.filename)
            CrMangaDownloadr::ImageDownloader.new(image.host).fetch(image.path, image_file)
            downloads_channel.send image_file
          }
        end
        images_slice.size.times do
          downloads << downloads_channel.receive
        end
        puts "Images downloaded so far: #{downloads.try &.size}"
      end
      puts "Number of images downloaded: #{downloads.try &.size}"
      downloads
    end

    def run
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
