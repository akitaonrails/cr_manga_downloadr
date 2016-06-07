require "cr_chainable_methods"
include CrChainableMethods::Pipe

module CrMangaDownloadr
  class Workflow
    def initialize(@config : Config); end

    def run
      Dir.mkdir_p @config.download_directory

      pipe fetch_chapters
        .>> fetch_pages
        .>> fetch_images
        .>> download_images
        .>> optimize_images
        .>> prepare_volumes

      puts "Done!"
    end

    def run_tests
      Dir.mkdir_p "/tmp/cr_manga_downloadr_cache"

      # the tests don't need to actually download, optimize and compile the pdfs
      pipe fetch_chapters
        .>> fetch_pages
        .>> fetch_images

      puts "Done!"
    end

    private def fetch_chapters
      puts "Fetching chapters ..."
      chapters = Chapters.new(@config.domain, @config.root_uri, @config.cache_http).fetch
      puts "Number of Chapters: #{chapters.try &.size}"
      chapters
    end

    private def fetch_pages(chapters : Array(String)?)
      puts "Fetching pages from all chapters ..."
      reactor = Concurrency.new(@config)
      reactor.fetch(chapters, Pages) do |link, engine|
        engine.try(&.fetch(link))
      end
    end

    private def fetch_images(pages : Array(String)?)
      puts "Fetching the Image URLs from each Page ..."
      reactor = Concurrency.new(@config)
      reactor.fetch(pages, PageImage) do |link, engine|
        [ engine.try(&.fetch(link)).as(Image) ]
      end
    end

    private def download_images(images : Array(Image)?)
      puts "Downloading each image ..."
      reactor = Concurrency.new(@config, false)
      reactor.fetch(images, ImageDownloader) do |image, _|
        image_file = File.join(@config.download_directory, image.filename)
        unless File.exists?(image_file)
          engine = ImageDownloader.new(image.host)
          engine.fetch(image.path, image_file)
          engine.close
        end
        [ image_file ]
      end
    end

    private def optimize_images(downloads : Array(String))
      puts "Running mogrify to convert all images down to Kindle supported size (600x800)"
      `mogrify -resize #{@config.image_dimensions} #{@config.download_directory}/*.jpg`
      downloads
    end

    private def prepare_volumes(downloads : Array(String))
      manga_name = @config.download_directory.split("/").try &.last
      index = 1
      downloads.each_slice(@config.pages_per_volume) do |batch|
        volume_directory = "#{@config.download_directory}/#{manga_name}_#{index}"
        volume_file = "#{volume_directory}.pdf"
        Dir.mkdir_p volume_directory

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
  end
end
