require "../spec_helper"

describe CrMangaDownloadr::PageImage do
  it "should fetch the image metadata of the page" do
    WebMock.stub(:get, "www.mangareader.net/naruto/662/2").
      to_return(status: 200, body: File.read("spec/fixtures/naruto_662_2.html"))

    image = CrMangaDownloadr::PageImage.new("www.mangareader.net").fetch("/naruto/662/2")

    image.try(&.host).should eq("i8.mangareader.net")
    image.try(&.path).should eq("/naruto/662/naruto-4739563.jpg")
    image.try(&.filename).should eq("Naruto-Chap-00662-Pg-00002.jpg")
  end
end
