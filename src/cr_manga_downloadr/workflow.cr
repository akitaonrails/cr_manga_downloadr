require "cr_chainable_methods"
include CrChainableMethods::Pipe

module CrMangaDownloadr
  class Workflow
    def initialize(@config : Config); end

    def run
      Dir.mkdir_p @config.download_directory

      pipe Steps.fetch_chapters(@config)
        .>> Steps.fetch_pages(@config)
        .>> Steps.fetch_images(@config)
        .>> Steps.download_images(@config)
        .>> Steps.optimize_images(@config)
        .>> Steps.prepare_volumes(@config)
        .>> unwrap

      puts "Done!"
    end

    def run_tests
      tmp_dir = "/tmp/cr_manga_downloadr_cache"
      if Dir.exists?(tmp_dir)
      	Dir.rmdir tmp_dir
      end
      Dir.mkdir_p tmp_dir

      # the tests don't need to actually download, optimize and compile the pdfs
      pipe Steps.fetch_chapters(@config)
        .>> Steps.fetch_pages(@config)
        .>> Steps.fetch_images(@config)
        .>> Steps.download_images(@config)
        .>> unwrap

      puts "Done!"
    end
  end

  module Steps
    def self.fetch_chapters(config : Config)
      puts "Fetching chapters ..."
      chapters = Chapters.new(config.domain, config.root_uri, config.cache_http).fetch
      puts "Number of Chapters: #{chapters.try &.size}"
      chapters
    end

    def self.fetch_pages(chapters : Array(String)?, config : Config)
      puts "Fetching pages from all chapters ..."
      reactor = Concurrency.new(config)
      reactor.fetch(chapters, Pages) do |link, engine|
        engine.try(&.fetch(link))
      end
    end

    def self.fetch_images(pages : Array(String)?, config : Config)
      puts "Fetching the Image URLs from each Page ..."
      reactor = Concurrency.new(config)
      reactor.fetch(pages, PageImage) do |link, engine|
        [ engine.try(&.fetch(link)).as(Image) ]
      end
    end

    def self.download_images(images : Array(Image)?, config : Config)
      puts "Downloading each image ..."
      reactor = Concurrency.new(config, false)
      reactor.fetch(images, ImageDownloader) do |image, _|
        image_file = File.join(config.download_directory, image.filename)
        unless File.exists?(image_file)
          engine = ImageDownloader.new(image.host)
          engine.fetch(image.path, image_file)
          engine.close
        end
        [ image_file ]
      end
    end

    def self.optimize_images(downloads : Array(String), config : Config)
      puts "Running mogrify to convert all images down to Kindle supported size (600x800)"
      `mogrify -resize #{config.image_dimensions} #{config.download_directory}/*.jpg`
      downloads
    end

    def self.prepare_volumes(downloads : Array(String), config : Config)
      manga_name = config.download_directory.split("/").try &.last
      index = 1
      downloads.each_slice(config.pages_per_volume) do |batch|
        volume_directory = "#{config.download_directory}/#{manga_name}_#{index}"
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
