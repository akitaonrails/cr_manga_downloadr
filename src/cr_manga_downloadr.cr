require "./cr_manga_downloadr/*"

module CrMangaDownloadr
  def self.main
    domain = "www.mangareader.net"
    chapters = CrMangaDownloadr::Chapters.new(domain, "/93/naruto.html").fetch
    chapter_link = chapters.try &.first
    puts chapter_link
    pages = CrMangaDownloadr::Pages.new(domain, chapter_link as String).fetch
    page_link = pages.try &.first
    puts page_link
    image = CrMangaDownloadr::PageImage.new(domain, chapter_link as String, page_link as String).fetch
    puts image
  end
end

# CrMangaDownloadr.main

