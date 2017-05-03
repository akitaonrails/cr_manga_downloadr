require "http/client"
require "xml"
require "openssl"

module CrMangaDownloadr
  class DownloadrClient
    @http_client : HTTP::Client
    def initialize(@domain : String, @cache_http = false)
      @http_client = http_client!
    end

    def close
      @http_client.try &.close
    end

    # FIXME: must unify the several different fetch signatures

    def fetch
      raise "must implement"
    end

    def fetch(uri : String)
      raise "must implement"
    end

    def fetch(uri : String, filename : String)
      raise "must implement"
    end

    def http_client!
      HTTP::Client.new(@domain).tap do |c|
        c.connect_timeout = 30.seconds
        c.dns_timeout = 10.seconds
        c.read_timeout = 5.minutes
      end
    end

    def domain=(new_domain)
      @domain = new_domain
      close
      @http_client = http_client!
    end

    def get(uri : String, binary = false)
      # TODO move this cache directory to the config object
      Dir.mkdir_p("/tmp/cr_manga_downloadr_cache") unless Dir.exists?("/tmp/cr_manga_downloadr_cache")
      cache_path = "/tmp/cr_manga_downloadr_cache/#{cache_filename(uri)}"
      while true
        begin
          response = if @cache_http && File.exists?(cache_path)
            body = File.read(cache_path)
            HTTP::Client::Response.new(200, body)
          else
            @http_client.get(uri, headers: HTTP::Headers{ "User-Agent" => CrMangaDownloadr::USER_AGENT })
          end

          case response.status_code
          when 301
            uri = response.headers["Location"]
          when 200
            if ( binary || @cache_http ) && !File.exists?(cache_path)
              File.open(cache_path, "w") do |f|
                f.print response.body
              end
            end

            if binary
              return cache_path
            else
              return XML.parse_html(response.body)
            end
          end
        rescue IO::Timeout
          # TODO: naive infinite retry, it will loop infinitely if the link really doesn't exist
          # so should have a way to control the amount of retries per link
          puts "Sleeping over #{uri}"
          sleep 1
        end
      end
    end

    private def cache_filename(uri)
      OpenSSL::MD5.hash(uri).join("")
    end
  end
end
