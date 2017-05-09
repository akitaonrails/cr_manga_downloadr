require "../spec_helper"

describe CrMangaDownloadr::Concurrency do
  it "should process a large queue of jobs in batches, concurrently and signal through a channel" do
    config = CrMangaDownloadr::Config.new("foo.com", "/")
    reactor = CrMangaDownloadr::Concurrency(Int32, Int32).new(config, CrMangaDownloadr::Pages)
    collection = ( 1..10_000 ).to_a
    results = reactor.fetch(collection) do |item, _|
      [item]
    end
    # this strange check is because when having 'puts' in the inner pool loop it was missing some items
    ( (1..10_000).to_a - results.try(&.flatten) ).should eq([] of Int32)
    results.size.should eq(10_000)
  end
end
