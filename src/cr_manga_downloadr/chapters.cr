require "./downloadr_client"
require "xml"

module CrMangaDownloadr
  class Chapters < DownloadrClient
    def initialize(@domain, @root_uri : String)
      super(@domain)
    end

    def fetch
      get @root_uri do |html|
        nodes = html.xpath_nodes("//table[contains(@id, 'listing')]//td//a/@href")
        nodes.map &.text
      end
    end
  end
end
