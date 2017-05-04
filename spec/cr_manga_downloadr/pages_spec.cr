require "../spec_helper"

describe CrMangaDownloadr::Pages do
  it "should fetch all of the page links of a chapter" do
    WebMock.stub(:get, "www.mangareader.net/naruto/1").
      to_return(status: 200, body: File.read("spec/fixtures/naruto_1.html"))

    config = CrMangaDownloadr::Config.new("www.mangareader.net", "", "", 10, "", 10, true, "/tmp")
    pages = CrMangaDownloadr::Pages.new(config).fetch("/naruto/1")

    (pages.try &.size).should eq(53)
    (pages.try &.first).should eq("/naruto/1/1")
    (pages.try &.last).should eq("/naruto/1/53")
  end
end
