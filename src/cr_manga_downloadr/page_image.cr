require "./downloadr_client"
require "xml"

module CrMangaDownloadr
  class PageImage < DownloadrClient
    def initialize(@domain, @chapter_link : String, @page_link : String)
      super(@domain)
    end

    def fetch
      get "#{@chapter_link}/#{@page_link}" do |response|
        html = XML.parse_html(response.body)
        images = html.xpath("//img[contains(@id, 'img')]").as(XML::NodeSet)

        image_alt = images[0]["alt"]
        tokens = image_alt.try &.match(/^(.*?)\s\-\s(.*?)$/)

        image_src = images[0]["src"]
        uri = ( URI.parse(image_src as String).try &.path || "")
        extension = File.extname(uri)

        {tokens.try &.[](1), "#{tokens.try &.[](2)}#{extension}", image_src}
      end
    end
  end
end
