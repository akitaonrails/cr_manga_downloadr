require "http/client"
require "xml"
require "openssl"

module CrMangaDownloadr
  class DownloadrClient
    @http_client : HTTP::Client
    @domain : String
    @cache_http : Bool

    def initialize(@config : CrMangaDownloadr::Config)
      @domain = @config.domain
      @cache_http = @config.cache_http
      @http_client = http_client!
    end

    def close
      @http_client.try &.close
    end

    # FIXME: must unify the several different fetch signatures

    def fetch(uri : String)
      raise "must implement"
    end

    def fetch_to(uri : String, filename : String)
      raise "must implement"
    end

    def http_client!
      HTTP::Client.new(@domain).tap do |c|
        c.connect_timeout = 5.seconds
        c.dns_timeout = 5.seconds
        c.read_timeout = 5.minutes
      end
    end

    def domain=(new_domain)
      @domain = new_domain
      close
      @http_client = http_client!
    end

    def get(uri : String, binary = false)
      Dir.mkdir_p(@config.cache_directory) unless Dir.exists?(@config.cache_directory)
      cache_path = File.join(@config.cache_directory, cache_filename(uri))
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
