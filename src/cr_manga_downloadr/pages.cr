require "./downloadr_client"
require "xml"

module CrMangaDownloadr
  class Pages < DownloadrClient(Array(String))
    def fetch(chapter_link : String)
      get chapter_link do |html|
        nodes = html.xpath_nodes("//div[@id='selectpage']//select[@id='pageMenu']//option")
        nodes.map { |node| [chapter_link, node.text as String].join("/") }
      end
    end
  end
end
