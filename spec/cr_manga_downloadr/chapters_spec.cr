require "../spec_helper"

describe CrMangaDownloadr::Chapters do
  it "should fetch all of the manga main chapter links" do
    WebMock.stub(:get, "www.mangareader.net/naruto").
      to_return(status: 200, body: File.read("spec/fixtures/naruto.html"))

    config = CrMangaDownloadr::Config.new("www.mangareader.net", "/naruto", "", 10, "", 10, true, "/tmp")
    chapters = CrMangaDownloadr::Chapters.new(config).fetch

    (chapters.try &.size).should eq(700)
    (chapters.try &.first).should eq("/naruto/1")
  end
end
