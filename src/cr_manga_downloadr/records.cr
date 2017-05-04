module CrMangaDownloadr
  record Image,
    host : String,
    path : String,
    filename : String

  record Config,
    domain : String,
    root_uri : String,
    download_directory : String,
    download_batch_size : Int32,
    image_dimensions : String,
    pages_per_volume : Int32,
    cache_http : Bool,
    cache_directory : String

  USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/45.0.2454.101 Chrome/45.0.2454.101 Safari/537.36"
end
