require "./downloadr_client"

module CrMangaDownloadr
  class ImageDownloader < DownloadrClient
    def fetch(image_src : String, filename : String)
      cache_path = get(image_src, true)
      File.delete(filename) if File.exists?(filename)
      File.rename(cache_path, filename)
    end
  end
end
