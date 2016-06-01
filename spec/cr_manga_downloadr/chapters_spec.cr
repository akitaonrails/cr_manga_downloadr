require "../spec_helper"

describe CrMangaDownloadr::Chapters do
  it "should fetch all of the manga main chapter links" do
    WebMock.stub(:get, "www.mangareader.net/naruto").
      to_return(status: 200, body: File.read("spec/fixtures/naruto.html"))

    chapters = CrMangaDownloadr::Chapters.new("www.mangareader.net", "/naruto").fetch

    (chapters.try &.size).should eq(700)
    (chapters.try &.first).should eq("/naruto/1")
  end
end
