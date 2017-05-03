require "./downloadr_client"

module CrMangaDownloadr
  class ImageDownloader < DownloadrClient
    def fetch(image_src : String, filename : String)
      cache_path = get(image_src, true).as(String)
      File.delete(filename) if File.exists?(filename)
      File.rename(cache_path, filename)
    end
  end
end
