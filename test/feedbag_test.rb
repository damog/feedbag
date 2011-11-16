require File.dirname(__FILE__) + '/test_helper'

class FeedbagTest < ActiveSupport::TestCase
  
  test "Feedbag.feed? should know that an RSS url is a feed" do
    rss_url = 'http://example.com/rss/'
    Feedbag.stubs(:find).with(rss_url).returns([rss_url])
    
    assert Feedbag.feed?(rss_url)
  end
  
  test "Feedbag.feed? should know that an RSS url with parameters is a feed" do
    rss_url = "http://example.com/data?format=rss"
    Feedbag.stubs(:find).with(rss_url).returns([rss_url])
    
    assert Feedbag.feed?(rss_url)
  end

  test "Feedbag find should discover feeds containing atom:link" do
    feeds = []
    feeds << 'http://www.psfk.com/feeds/mashable'
    feeds << 'http://jenniferlynch.wordpress.com/feed'
    feeds << 'http://lurenbijdeburen.wordpress.com/feed'

    feeds.each do |url|
      assert_equal [url], Feedbag.find(url)
    end
  end

end
