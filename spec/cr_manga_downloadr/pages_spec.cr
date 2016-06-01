require "../spec_helper"

describe CrMangaDownloadr::Pages do
  it "should fetch all of the page links of a chapter" do
    WebMock.stub(:get, "www.mangareader.net/naruto/1").
      to_return(status: 200, body: File.read("spec/fixtures/naruto_1.html"))

    pages = CrMangaDownloadr::Pages.new("www.mangareader.net", "/naruto/1").fetch

    (pages.try &.size).should eq(53)
    (pages.try &.first).should eq("1")
    (pages.try &.last).should eq("53")
  end
end
