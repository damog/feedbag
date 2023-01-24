# frozen_string_literal: true

require 'test_helper'

class FeedbagTest < Test::Unit::TestCase
  context 'Feedbag.feed? should know that an RSS url is a feed' do
    before do
      @rss_url = 'http://example.com/rss/'
      Feedbag.stubs(:find).with(@rss_url).returns([@rss_url])
    end
    should 'return true' do
      assert Feedbag.feed?(@rss_url)
    end
  end

  context 'Feedbag.feed? should know that an RSS url with parameters is a feed' do
    before do
      @rss_url = 'http://example.com/data?format=rss'
      Feedbag.stubs(:find).with(@rss_url).returns([@rss_url])
    end
    should 'return true' do
      assert Feedbag.feed?(@rss_url)
    end
  end

  context 'Feedbag find should discover feeds containing atom:link' do
    before do
      @feeds = ['http://jenniferlynch.wordpress.com/feed', 'http://lurenbijdeburen.wordpress.com/feed']
    end
    should 'find atom feed' do
      @feeds.each do |url|
        assert_equal [url], Feedbag.find(url)
      end
    end
  end

  context 'Feedbag#looks_like_feed? should assume that url with proper extension is a feed' do
    before do
      @feeds = ['http://feeds.bbci.co.uk/news/rss.xml', 'http://feeds.bbci.co.uk/news/rss.rdf',
                'http://feeds.bbci.co.uk/news/rss.rss', 'http://feeds.bbci.co.uk/news/rss.xml?edition=int']
    end
    should 'return true' do
      @feeds.each do |url|
        assert Feedbag.new.looks_like_feed?(url)
      end
    end
  end

  context 'Feedbag find should discover JSON Feeds' do
    should 'find json feed' do
      src = 'test/testcases/json1.html'
      stub_request(:any, 'example3.com').to_return(body: File.new(src), status: 200,
                                                   headers: { 'Content-Type' => 'text/html' })
      result = Feedbag.find('http://example3.com')

      assert result.include?('https://blog.booko.com.au/feed/json/')
      assert result.include?('https://blog.booko.com.au/feed/')
      assert result.include?('https://blog.booko.com.au/comments/feed/')
    end
  end

  context 'Feedbag should follow redirects' do
    should 'follow redirects' do
      src = 'test/testcases/json1.html'

      stub_request(:any, 'example1.com').to_return(status: 301,
                                                   headers: {
                                                     'Location' => '//example2.com', 'Content-Type' => 'text/html'
                                                   })
      stub_request(:any, 'example2.com').to_return(body: File.new(src), status: 200,
                                                   headers: { 'Content-Type' => 'text/html' })

      result = Feedbag.find('http://example1.com')
      assert result.include?('https://blog.booko.com.au/feed/json/')
    end
  end

  context 'Feedbag should send the correct User Agent' do
    should 'send correct user agent' do
      src = 'test/testcases/json1.html'
      default_user_agent = "Feedbag/#{Feedbag::VERSION}"

      stub_request(:any, 'example3.com').with(headers: { 'User-Agent' => "Feedbag/#{Feedbag::VERSION}" }).to_return(
        body: File.new(src), status: 200, headers: { 'Content-Type' => 'text/html' }
      )

      # This request does match the stub with the default User-Agent and should return a result
      result = Feedbag.find('http://example3.com')
      assert result.include?('https://blog.booko.com.au/feed/json/')

      # This request does not match the stub using the custom User-Agent
      result = Feedbag.find('http://example3.com', 'User-Agent' => 'My Personal Agent/1.0.1')
      assert result.empty?

      stub_request(:any, 'example4.com').with(headers: { 'User-Agent' => 'My Personal Agent/1.0.1' }).to_return(
        body: File.new(src), status: 200, headers: { 'Content-Type' => 'text/html' }
      )

      # This request does not match the stub using the default User-Agent
      result = Feedbag.find('http://example4.com')
      assert result.empty?

      # This request does match the stub with a custom User-Agent and should return a result
      result = Feedbag.find('http://example4.com', 'User-Agent' => 'My Personal Agent/1.0.1')
      assert result.include?('https://blog.booko.com.au/feed/json/')
    end
  end

  # context "Feedbag should pass other options to open-uri" do
  #  should "pass options to open-uri" do
  #  end
  # end

  context 'Feedbag should be able to find URLs with ampersands and plus signs' do
    before do
      @feed = 'https://link.springer.com/search.rss?facet-content-type=Article&amp;facet-journal-id=41116&amp;channel-name=Living+Reviews+in+Solar+Physics'
    end
    should 'return true' do
      assert Feedbag.new.looks_like_feed?(@feed)
    end
  end
end
