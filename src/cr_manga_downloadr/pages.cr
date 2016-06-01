require "./downloadr_client"
require "xml"

module CrMangaDownloadr
  class Pages < DownloadrClient
    def initialize(@domain, @chapter_link : String)
      super(@domain)
    end

    def fetch
      get @chapter_link do |response|
        html = XML.parse_html(response.body)
        nodes = html.xpath_nodes("//div[@id='selectpage']//select[@id='pageMenu']//option")
        nodes.map &.text
      end
    end
  end
end
