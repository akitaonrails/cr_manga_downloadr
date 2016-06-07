require "../spec_helper"

describe CrMangaDownloadr::Concurrency do
  it "should process a large queue of jobs in batches, concurrently and signal through a channel" do
    config = CrMangaDownloadr::Config.new("foo.com", "/", "/tmp", 10, "", 10)
    reactor = CrMangaDownloadr::Concurrency(Int32, Int32, CrMangaDownloadr::Pages).new(config, false)
    collection = ( 1..10_000 ).to_a
    results = reactor.fetch(collection) do |item, _|
      [item]
    end
    # this strange check is because when having 'puts' in the inner pool loop it was missing some items
    ( (1..10_000).to_a - results.try(&.flatten) ).should eq([] of Int32)
    results.size.should eq(10_000)
  end

  it "test the inner worker/pool implementation" do
    config = CrMangaDownloadr::Config.new("foo.com", "/", "/tmp", 10, "", 10)
    engine = CrMangaDownloadr::Concurrency(Int32, Int32, CrMangaDownloadr::Pages).new(config, false)
    queue = (1..100).to_a
    results = [] of Int32
    engine.pool(config.download_batch_size) do
      if queue.size > 0
        results << queue.pop
      else
        raise CrMangaDownloadr::ConcurrencyBreakException.new
      end
    end
    results.size.should eq(100)
  end
end
