require 'test_helper'

class FeedbagTest < Test::Unit::TestCase

  context "Feedbag.feed? should know that an RSS url is a feed" do
    setup do
      @rss_url = 'http://example.com/rss/'
      Feedbag.stubs(:find).with(@rss_url).returns([@rss_url])
    end
    should "return true" do
      assert Feedbag.feed?(@rss_url)
    end
  end

  context "Feedbag.feed? should know that an RSS url with parameters is a feed" do
    setup do
      @rss_url = "http://example.com/data?format=rss"
      Feedbag.stubs(:find).with(@rss_url).returns([@rss_url])
    end
    should "return true" do
      assert Feedbag.feed?(@rss_url)
    end
  end

  context "Feedbag find should discover feeds containing atom:link" do
    setup do
      @feeds = ['http://jenniferlynch.wordpress.com/feed', 'http://lurenbijdeburen.wordpress.com/feed']
    end
    should "find atom feed" do
      @feeds.each do |url|
        assert_equal [url], Feedbag.find(url)
      end
    end
  end

  context "Feedbag#looks_like_feed? should assume that url with proper extension is a feed" do
    setup do
      @feeds = ['http://feeds.bbci.co.uk/news/rss.xml', 'http://feeds.bbci.co.uk/news/rss.rdf',
                'http://feeds.bbci.co.uk/news/rss.rss', 'http://feeds.bbci.co.uk/news/rss.xml?edition=int']
    end
    should "return true" do
      @feeds.each do |url|
        assert Feedbag.new.looks_like_feed?(url)
      end
    end
  end

  context "Feedbag find should discover JSON Feeds" do
    should "find json feed" do
      src = 'test/testcases/json1.html'
      stub_request(:any, "example3.com").to_return(body: File.new(src), status: 200,  headers: {"Content-Type" => 'text/html'})
      result = Feedbag.find('http://example3.com')
      
      assert result.include?('https://blog.booko.com.au/feed/json/')
      assert result.include?('https://blog.booko.com.au/feed/')
      assert result.include?('https://blog.booko.com.au/comments/feed/')
    end
  end

end
