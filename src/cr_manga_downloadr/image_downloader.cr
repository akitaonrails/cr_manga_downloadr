require "./downloadr_client"

module CrMangaDownloadr
  class ImageDownloader < DownloadrClient(String)
    def fetch(image_src : String, filename : String)
      File.delete(filename) if File.exists?(filename)
      response = @http_client.get(image_src)
      case response.status_code
      when 301
        fetch(response.headers["Location"], filename)
      when 200
        File.open(filename, "w") do |f|
          f.print response.body
        end
      end
    rescue IO::Timeout
      sleep 1
      fetch(image_src, filename)
    end
  end
end
