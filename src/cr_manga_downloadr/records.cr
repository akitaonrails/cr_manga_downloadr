module CrMangaDownloadr
  record Image,
    host : String,
    path : String,
    filename : String

  record Config,
    domain : String,
    root_uri : String,
    download_directory : String = "/tmp",
    download_batch_size : Int32 = 10,
    image_dimensions : String = "600x800",
    pages_per_volume : Int32 = 250,
    cache_http : Bool = true,
    cache_directory : String = "/tmp/cr_manga_downloadr_cache"

  USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/45.0.2454.101 Chrome/45.0.2454.101 Safari/537.36"
end
