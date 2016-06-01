require "../spec_helper"

describe CrMangaDownloadr::PageImage do
  it "should fetch the image metadata of the page" do
    WebMock.stub(:get, "www.mangareader.net/naruto/662/2").
      to_return(status: 200, body: File.read("spec/fixtures/naruto_662_2.html"))

    image = CrMangaDownloadr::PageImage.new("www.mangareader.net", "/naruto/662", "2").fetch

    ( image.try &.[](0) ).should eq("Naruto 662")
    ( image.try &.[](1) ).should eq("Page 2.jpg")
    ( image.try &.[](2) ).should eq("http://i8.mangareader.net/naruto/662/naruto-4739563.jpg")
  end
end
