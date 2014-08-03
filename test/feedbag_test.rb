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

end
