require "../spec_helper"

describe CrMangaDownloadr::ImageDownloader do
  it "should download the image blob" do
    WebMock.stub(:get, "http://i8.mangareader.net/naruto/662/naruto-4739563.jpg").
      to_return(status: 200, body: File.read("spec/fixtures/naruto-4739563.jpg"))

    config = CrMangaDownloadr::Config.new("i8.mangareader.net", "")
    image = CrMangaDownloadr::ImageDownloader.new(config).
      fetch_to("/naruto/662/naruto-4739563.jpg", "/tmp/naruto.jpg")
    File.exists?("/tmp/naruto.jpg").should eq(true)
    File.size("/tmp/naruto.jpg").should eq(File.size("spec/fixtures/naruto-4739563.jpg"))
  end
end
