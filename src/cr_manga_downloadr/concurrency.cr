require "fiberpool"

module CrMangaDownloadr
  struct Concurrency
    def initialize(@config : Config, @turn_on_engine = true); end

    def fetch(collection : Array(A)?, engine_class : E.class, &block : A, E? -> Array(B)?) : Array(B)
      results = [] of B
      if collection
        pool = Fiberpool.new(collection, @config.download_batch_size)
        pool.run do |item|
          engine = if @turn_on_engine
                     engine_class.new(@config.domain)
                   end
          reply = block.call(item, engine)
          results.concat(reply)
        end
      end
      results
    end
  end
end
