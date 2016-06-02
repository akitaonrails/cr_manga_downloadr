module CrMangaDownloadr
  class Concurrency(A, B, C)
    def initialize(@config : Config); end

    def fetch(collection : Array(A), &block : A, C -> Array(B))
      results = [] of B
      collection.each_slice(@config.download_batch_size) do |batch|
        engine  = C.new(@config.domain)
        channel = Channel(Array(B)).new
        batch.each do |item|
          spawn {
            reply = block.call(item, engine)
            channel.send(reply)
          }
        end
        batch.size.times do
          results.concat(channel.receive.try &.flatten)
        end
        channel.close
        puts "Processed so far: #{results.try &.size}"
      end
      results
    end
  end
end
