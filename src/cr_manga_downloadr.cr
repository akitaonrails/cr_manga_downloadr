require "./cr_manga_downloadr/*"

module CrMangaDownloadr
  def self.main
    domain = "www.mangareader.net"
    chapters = CrMangaDownloadr::Chapters.new(domain, "/93/naruto.html").fetch
    chapter_link = chapters.try &.first
    puts chapter_link
    if chapter_link
      pages = CrMangaDownloadr::Pages.new(domain).fetch(chapter_link)
      page_link = pages.try &.first
      puts page_link
      if page_link
        image = CrMangaDownloadr::PageImage.new(domain).fetch(chapter_link, page_link)
        puts image
      end
    end
  end
end

CrMangaDownloadr.main
