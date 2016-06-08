require "fiberpool"

module CrMangaDownloadr
  class Concurrency(A, B, C)
    def initialize(@config : Config, @turn_on_engine = true); end

    def fetch(collection : Array(A)?, &block : A, C? -> Array(B)?) : Array(B)?
      results = [] of B
      if collection
        pool = Fiberpool.new(collection, @config.download_batch_size)
        pool.run do |item|
          engine = @turn_on_engine ? C.new(@config.domain, @config.cache_http) : nil
          reply = block.call(item as A, engine)
          results.concat(reply.try(&.flatten) as Array(B))
        end
      end
      results
    end
  end
end
