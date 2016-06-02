require "../spec_helper"

describe CrMangaDownloadr::Concurrency do
  it "should process a large queue of jobs in batches, concurrently and signal through a channel" do
    config = CrMangaDownloadr::Config.new("foo.com", "/", "/tmp", 10, "", 10)
    reactor = CrMangaDownloadr::Concurrency(Int32, Int32, CrMangaDownloadr::Pages).new(config, false)
    collection = ( 1..10_000 ).to_a
    results = reactor.fetch(collection) do |item, _|
      [item]
    end
    results.size.should eq(10_000)
    results.sort.should eq(collection)
  end
end
