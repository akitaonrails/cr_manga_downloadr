require "./downloadr_client"
require "xml"

module CrMangaDownloadr
  class Pages < DownloadrClient
    def fetch(chapter_link : String)
      get chapter_link do |html|
        nodes = html.xpath_nodes("//div[@id='selectpage']//select[@id='pageMenu']//option")
        nodes.map &.text
      end
    end
  end
end
