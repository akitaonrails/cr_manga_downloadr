require "./cr_manga_downloadr/*"
require "option_parser"
require "uri"
require "benchmark"

opt_manga_directory = "/tmp"
opt_manga_root_uri = ""
opt_batch_size = 50
opt_resize_format = "600x800"
opt_pages_per_volume = 250
opt_run_tests = false
opt_cache_pages = false
opt_cache_directory = "/tmp/cr_manga_downloadr_cache"

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

  opts.on( "-b BATCH_SIZE", "-batch 50", "the amount of concurrent HTTP fetches to the MangaReader site, don't overdo it") do |batch|
    opt_batch_size = batch.to_i
  end

  opts.on( "-r FORMAT", "--resize 600x800", "the current Kindle format is 600x800 but you can change it") do |format|
    opt_resize_format = format
  end

  opts.on( "-v PAGES", "--volume 250", "how many pages should each PDF volume have") do |volume|
    opt_pages_per_volume = volume.to_i
  end

  opts.on( "-c", "--cache", "turn on the HTTP cache so you can resume a process if you needed to stop before ending") do |_|
    opt_cache_pages = true
  end

  opts.on( "-t", "--test", "run a simulation to one-punch man manga") do |_|
    opt_manga_root_uri = "http://www.mangareader.net/onepunch-man"
    opt_manga_directory = "/tmp/cr_one_punch"
    opt_run_tests = true
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
  config = CrMangaDownloadr::Config.new(root_uri.host.as(String),
                                        root_uri.path.as(String),
                                        opt_manga_directory,
                                        opt_batch_size,
                                        opt_resize_format,
                                        opt_pages_per_volume,
                                        opt_cache_pages,
                                        opt_cache_directory)
  workflow = CrMangaDownloadr::Workflow.new(config)
  if opt_run_tests
    puts Benchmark.measure("One-Punch Man test") {
      workflow.run_tests
    }
  else
    workflow.run
  end
end
