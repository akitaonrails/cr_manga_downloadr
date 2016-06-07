module CrMangaDownloadr
  class ConcurrencyBreakException < Exception; end

  class Concurrency(A, B, C)
    def initialize(@config : Config, @turn_on_engine = true); end

    def fetch(collection : Array(A)?, &block : A, C? -> Array(B)?) : Array(B)?
      results = [] of B
      pool @config.download_batch_size do
        if (collection.try(&.size) || 0) > 0
          item = collection.try(&.pop)
          engine = @turn_on_engine ? C.new(@config.domain) : nil
          reply = block.call(item as A, engine)
          results.concat(reply.try(&.flatten) as Array(B))
        else
          raise ConcurrencyBreakException.new
        end
      end
      results
    end

    # pool/worker methods inspired by this stackoverflow answer: http://stackoverflow.com/a/30854065/1529907

    def worker(&block)
      signal_channel = Channel::Unbuffered(Exception).new

      spawn do
        begin
          block.call
        rescue ex
          signal_channel.send(ex)
        else
          signal_channel.send(Exception.new(nil))
        end
      end

      signal_channel.receive_op
    end

    def pool(max_num_of_workers = 10, &block)
      pool_counter = 0
      workers_channels = [] of Channel::ReceiveOp(Channel::Unbuffered(Exception), Exception)

      loop do
        while pool_counter < max_num_of_workers
          pool_counter += 1
          workers_channels << worker(&block)
        end

        index, signal_exception = Channel.select(workers_channels)
        workers_channels.delete_at(index)
        pool_counter -= 1

        if signal_exception.is_a?(ConcurrencyBreakException)
          break
        elsif signal_exception.message.nil?
          # does nothing, just signalling to continue
        else
          puts "ERROR: #{signal_exception.message}"
        end
      end
    end
  end
end
