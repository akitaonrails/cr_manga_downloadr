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
    pages_per_volume : Int32
end
