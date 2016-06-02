module CrMangaDownloadr
  record Image,
    host : String,
    path : String,
    filename : String

  record Config,
    domain : String,
    root_uri : String,
    download_directory : String,
    download_batch_size : Int32
end
