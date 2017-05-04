require "./downloadr_client"
require "xml"

module CrMangaDownloadr
  class Chapters < DownloadrClient
    @root_uri : String

    def initialize(@config : CrMangaDownloadr::Config)
      super(@config)
      @root_uri = @config.root_uri
    end

    def fetch
      html = get(@root_uri)
      nodes = html.as(XML::Node).xpath_nodes("//table[contains(@id, 'listing')]//td//a/@href")
      nodes.map { |node| node.text.as(String) }
    end
  end
end
