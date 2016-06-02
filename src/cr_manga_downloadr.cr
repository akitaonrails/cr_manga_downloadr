require "./cr_manga_downloadr/*"
require "option_parser"
require "uri"

opt_manga_directory = "/tmp"
opt_manga_root_uri = ""

OptionParser.parse! do |opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner = "Scraps all the images from all pages of a MangaReader.net manga"

  opts.on( "-d DIRECTORY", "--d DIRECTORY", "the directory path where to save the manga" ) do |directory|
    opt_manga_directory = directory
  end

  opts.on( "-u URL", "--url URL", "the MangaReader full URI to the chapters index of the manga" ) do |url|
    opt_manga_root_uri = url
  end

  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on( "-h", "--help", "Display this screen" ) do
    puts opts
    exit
  end
end

if opt_manga_root_uri.size > 0
  root_uri = URI.parse(opt_manga_root_uri)
  config = CrMangaDownloadr::Config.new(root_uri.host as String, root_uri.path as String, opt_manga_directory, 50)
  workflow = CrMangaDownloadr::Workflow.new(config)
  workflow.run
end
