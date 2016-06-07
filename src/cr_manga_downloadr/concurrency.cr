module CrMangaDownloadr
  struct Concurrency
    def initialize(@config : Config, @turn_on_engine = true); end

    def fetch(collection : Array(A)?, engine_class : E.class, &block : A, E? -> Array(B)?) : Array(B)
      results = [] of B
      collection.try &.each_slice(@config.download_batch_size) do |batch|
        channel = Channel(Array(B)).new
        batch.each do |item|
          spawn {
            engine = if @turn_on_engine
                       engine_class.new(@config.domain)
                     end
            reply = block.call(item, engine)
            channel.send(reply) if reply
            engine.try &.close
          }
        end
        batch.size.times do
          reply = channel.receive
          results.concat(reply)
        end
        channel.close
        puts "Processed so far: #{results.try &.size}"
      end
      results
    end
  end
end
