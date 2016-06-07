require "./downloadr_client"
require "xml"

module CrMangaDownloadr
  class Chapters < DownloadrClient
    def initialize(domain, @root_uri : String)
      super(domain)
    end

    def fetch
      html = get(@root_uri)
      nodes = html.xpath_nodes("//table[contains(@id, 'listing')]//td//a/@href")
      nodes.map { |node| node.text.as(String) }
    end
  end
end
