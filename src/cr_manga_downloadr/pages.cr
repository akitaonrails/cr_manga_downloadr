require "./downloadr_client"
require "xml"

module CrMangaDownloadr
  class Pages < DownloadrClient
    def fetch(chapter_link : String)
      html = get(chapter_link).as(XML::Node)
      nodes = html.xpath_nodes("//div[@id='selectpage']//select[@id='pageMenu']//option")
      nodes.map { |node| "#{chapter_link}/#{node.text}" }
    end
  end
end
