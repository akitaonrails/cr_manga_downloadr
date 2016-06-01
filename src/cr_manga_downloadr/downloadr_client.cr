require "http/client"

module CrMangaDownloadr
  class DownloadrClient
    @http_client : HTTP::Client
    def initialize(@domain : String)
      @http_client = HTTP::Client.new(@domain).tap do |c|
        c.connect_timeout = 30.seconds
        c.dns_timeout = 10.seconds
        c.read_timeout = 5.minutes
      end
    end

    def finalize
      @http_client.try &.close
    end

    def get(uri : String, &block : HTTP::Client::Response -> Array(String?) | Tuple(String?, String?, String?))
      response = @http_client.get(uri)
      case response.status_code
      when 301
        get response.headers["Location"], &block
      when 200
        block.call(response)
      end
    rescue IO::Timeout
      # TODO: naive infinite retry, it will loop infinitely if the link really doesn't exist
      # so should have a way to control the amount of retries per link
      sleep 1
      get(uri, &block)
    end
  end
end
