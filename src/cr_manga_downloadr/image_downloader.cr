require "./downloadr_client"

module CrMangaDownloadr
  class ImageDownloader < DownloadrClient
    def fetch_to(image_src : String, filename : String)
      cache_path = get(image_src, true).as(String)
      File.delete(filename) if File.exists?(filename)
      Dir.mkdir_p(File.dirname(filename)) unless Dir.exists?(File.dirname(filename))
      File.rename(cache_path, filename)
    end
  end
end
