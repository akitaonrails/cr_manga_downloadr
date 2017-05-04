require "fiberpool"

module CrMangaDownloadr
  struct Concurrency(A, B)
    def initialize(@config : Config, @engine_class : DownloadrClient.class); end

    def fetch(collection : Array(A)?, &block : A, DownloadrClient -> Array(B)?) : Array(B)
      results = [] of B
      if collection
        pool = Fiberpool.new(collection, @config.download_batch_size)
        pool.run do |item|
          engine = @engine_class.new(@config)
          if reply = block.call(item, engine)
            results.concat(reply)
          end
        end
      end
      results
    end
  end
end
