# frozen_string_literal: true

require "test_helper"

class AsyncFeedbagTest < Test::Unit::TestCase
  context "AsyncFeedbag.feed? should know that an RSS url is a feed" do
    setup do
      @rss_url = "http://example.com/rss/"
      AsyncFeedbag.stubs(:find).with(@rss_url).returns([@rss_url])
    end

    should "return true" do
      assert AsyncFeedbag.feed?(@rss_url)
    end
  end

  context "AsyncFeedbag.feed? should know that an RSS url with parameters is a feed" do
    setup do
      @rss_url = "http://example.com/data?format=rss"
      AsyncFeedbag.stubs(:find).with(@rss_url).returns([@rss_url])
    end

    should "return true" do
      assert AsyncFeedbag.feed?(@rss_url)
    end
  end

  context "AsyncFeedbag find should discover feeds containing atom:link" do
    setup do
      @feeds = ["https://specialmomsblog.mom/feed", "http://lurenbijdeburen.wordpress.com/feed"]
      stub_request(:get, "http://lurenbijdeburen.wordpress.com/feed")
        .with(headers: { "User-Agent" => "AsyncFeedbag/2.0.0" })
        .to_return(File.read("test/webfixtures/lurenbijdeburen.wordpress.com.feed"))
      stub_request(:get, "https://specialmomsblog.mom/feed")
        .with(headers: { "User-Agent" => "AsyncFeedbag/2.0.0" })
        .to_return(File.read("test/webfixtures/specialmomsblog.feed"))
    end
    should "find atom feed" do
      @feeds.each do |url|
        assert_equal [url], AsyncFeedbag.find(url)
      end
    end
  end

  context "AsyncFeedbag#looks_like_feed? should assume that url with proper extension is a feed" do
    setup do
      @feeds = ["http://feeds.bbci.co.uk/news/rss.xml", "http://feeds.bbci.co.uk/news/rss.rdf",
                "http://feeds.bbci.co.uk/news/rss.rss", "http://feeds.bbci.co.uk/news/rss.xml?edition=int"]
    end
    should "return true" do
      @feeds.each do |url|
        assert AsyncFeedbag.new.looks_like_feed?(url)
      end
    end
  end

  context "AsyncFeedbag find should discover JSON Feeds" do
    should "find json feed" do
      src = "test/testcases/json1.html"
      stub_request(:any, "example3.com").to_return(body: File.new(src), status: 200, headers: { "Content-Type" => "text/html" })
      result = AsyncFeedbag.find("http://example3.com")

      assert_includes result, "https://blog.booko.com.au/feed/json/"
      assert_includes result, "https://blog.booko.com.au/feed/"
      assert_includes result, "https://blog.booko.com.au/comments/feed/"
    end
  end

  context "AsyncFeedbag should follow redirects" do
    should "follow scheme redirects" do
      src = "test/testcases/json1.html"

      stub_request(:get, "http://example1.com").to_return(status: 301, headers: { "Location" => "https://example1.com", "Content-Type" => "text/html" })
      stub_request(:get, "https://example1.com").to_return(body: File.new(src), status: 200,  headers: { "Content-Type" => "text/html" })

      result = AsyncFeedbag.find("http://example1.com")

      assert_includes result, "https://blog.booko.com.au/feed/json/"
    end
    should "follow redirects" do
      src = "test/testcases/json1.html"

      stub_request(:any, "example1.com").to_return(status: 301, headers: { "Location" => "/feed2", "Content-Type" => "text/html" })
      stub_request(:get, "example1.com/feed2").to_return(body: File.new(src), status: 200,  headers: { "Content-Type" => "text/html" })

      result = AsyncFeedbag.find("http://example1.com")

      assert_includes result, "https://blog.booko.com.au/feed/json/"
    end
  end

  context "AsyncFeedbag should send the correct User Agent" do
    should "send correct user agent" do
      src = "test/testcases/json1.html"

      stub_request(:any, "example3.com").with(headers: { "User-Agent" => "AsyncFeedbag/#{AsyncFeedbag::VERSION}" }).to_return(body: File.new(src), status: 200, headers: { "Content-Type" => "text/html" })

      # This request does match the stub with the default User-Agent and should return a result
      result = AsyncFeedbag.find("http://example3.com")

      assert_includes result, "https://blog.booko.com.au/feed/json/"

      stub_request(:any, "example3.com").to_return(body: "", status: 200, headers: { "Content-Type" => "text/html" })
      # This request does not match the stub using the custom User-Agent
      result = AsyncFeedbag.find("http://example3.com", "User-Agent" => "My Personal Agent/1.0.1")

      assert_empty result

      stub_request(:any, "example4.com").to_return(body: "", status: 200, headers: { "Content-Type" => "text/html" })

      # This request does not match the stub using the default User-Agent
      result = AsyncFeedbag.find("http://example4.com")

      assert_empty result

      stub_request(:any, "example4.com").with(headers: { "User-Agent" => "My Personal Agent/1.0.1" }).to_return(body: File.new(src), status: 200, headers: { "Content-Type" => "text/html" })
      # This request does match the stub with a custom User-Agent and should return a result
      result = AsyncFeedbag.find("http://example4.com", "User-Agent" => "My Personal Agent/1.0.1")

      assert_includes result, "https://blog.booko.com.au/feed/json/"
    end
  end

  # context "AsyncFeedbag should pass other options to open-uri" do
  #  should "pass options to open-uri" do
  #  end
  # end

  context "AsyncFeedbag should be able to find URLs with ampersands and plus signs" do
    setup do
      @feed = "https://link.springer.com/search.rss?facet-content-type=Article&amp;facet-journal-id=41116&amp;channel-name=Living+Reviews+in+Solar+Physics"
    end

    should "return true" do
      assert AsyncFeedbag.new.looks_like_feed?(@feed)
    end
  end
end
