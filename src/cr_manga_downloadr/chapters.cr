require "./downloadr_client"
require "xml"

module CrMangaDownloadr
  class Chapters < DownloadrClient
    def initialize(@domain, @root_uri : String, @cache_http = false)
      super(@domain, @cache_http)
    end

    def fetch
      html = get(@root_uri)
      nodes = html.as(XML::Node).xpath_nodes("//table[contains(@id, 'listing')]//td//a/@href")
      nodes.map { |node| node.text.as(String) }
    end
  end
end
