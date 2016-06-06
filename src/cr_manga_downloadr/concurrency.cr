module CrMangaDownloadr
  class Concurrency(A, B, C)
    def initialize(@config : Config, @turn_on_engine = true); end

    def fetch(collection : Array(A)?, &block : A, C? -> Array(B)?) : Array(B)?
      results = [] of B
      collection.try &.each_slice(@config.download_batch_size) do |batch|
        channel = Channel(Array(B)?).new
        batch.each do |item|
          spawn {
            engine  = if @turn_on_engine
                    C.new(@config.domain)
                  end
            reply = block.call(item, engine)
            channel.send(reply)
          }
        end
        batch.size.times do
          reply = channel.receive
          if reply
            results.concat(reply.flatten)
          end
        end
        channel.close
        puts "Processed so far: #{results.try &.size}"
      end
      results
    end
  end
end
