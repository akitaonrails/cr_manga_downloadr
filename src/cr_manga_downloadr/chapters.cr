require "./downloadr_client"
require "xml"

module CrMangaDownloadr
  class Chapters < DownloadrClient
    def initialize(@domain, @root_uri : String)
      super(@domain)
    end

    def fetch
      get @root_uri do |response|
        html = XML.parse_html(response.body)
        nodes = html.xpath_nodes("//table[contains(@id, 'listing')]//td//a/@href")
        nodes.map &.text
      end
    end
  end
end
