require "./downloadr_client"
require "xml"
require "uri"

module CrMangaDownloadr
  class PageImage < DownloadrClient
    def fetch(page_link : String)
      html = get(page_link)
      images = html.as(XML::Node).xpath("//img[contains(@id, 'img')]").as(XML::NodeSet)

      image_alt = images[0]["alt"]
      image_src = images[0]["src"]

      if image_alt && image_src
        extension      = image_src.split(".").last
        list           = image_alt.split(" ").reverse
        title_name     = list[4..-1].join(" ")
        chapter_number = list[3].rjust(5, '0')
        page_number    = list[0].rjust(5, '0')

        uri = URI.parse(image_src)
        CrMangaDownloadr::Image.new(uri.host.as(String),
                                    uri.path.as(String),
                                    "#{title_name}-Chap-#{chapter_number}-Pg-#{page_number}.#{extension}")
      else
        raise Exception.new("Couldn't find proper metadata alt in the image tag")
      end
    end
  end
end
