require "http/client"
require "xml"

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

    def close
      @http_client.try &.close
    end

    def get(uri : String)
      while true
        begin
          response = @http_client.get(uri, headers: HTTP::Headers{"User-Agent": CrMangaDownloadr::USER_AGENT})
          case response.status_code
          when 301
            uri = response.headers["Location"]
          when 200
            return XML.parse_html(response.body)
          end
        rescue IO::Timeout
          # TODO: naive infinite retry, it will loop infinitely if the link really doesn't exist
          # so should have a way to control the amount of retries per link
          puts "Sleeping over #{uri}"
          sleep 1
        end
      end
    end
  end
end
