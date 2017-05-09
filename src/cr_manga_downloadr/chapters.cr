require "./downloadr_client"
require "xml"

module CrMangaDownloadr
  class Chapters < DownloadrClient
    def fetch
      html = get(@config.root_uri).as(XML::Node)
      nodes = html.xpath_nodes("//table[contains(@id, 'listing')]//td//a/@href")
      nodes.map { |node| node.text.as(String) }
    end
  end
end
