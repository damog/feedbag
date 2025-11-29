#!/usr/bin/env ruby
# Test for non-ASCII URL support (Issue #29)

require 'rubygems'
require 'test/unit'

# Add user gems to load path for addressable
gem_home = File.expand_path('~/.gem/ruby/2.6.0')
$LOAD_PATH.unshift(File.join(gem_home, 'gems', 'addressable-2.8.8', 'lib'))
$LOAD_PATH.unshift(File.join(gem_home, 'gems', 'public_suffix-5.1.1', 'lib'))

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'feedbag'

class NormalizeUrlTest < Test::Unit::TestCase
  
  def test_normalize_chinese_characters_in_url_path
    url = "https://www.rehabsociety.org.hk/zh-hant/主頁/feed/"
    normalized = Feedbag.normalize_url(url)
    
    # Should start with the expected domain
    assert_match(/^https:\/\/www\.rehabsociety\.org\.hk\/zh-hant\//, normalized)
    # Should be percent-encoded (主頁 becomes %E4%B8%BB%E9%A0%81)
    assert_match(/%E4%B8%BB%E9%A0%81/, normalized)
    # Original non-ASCII characters should be gone
    refute_match(/主頁/, normalized)
  end

  def test_normalize_japanese_characters_in_url_path
    url = "https://www.example.jp/日本語/rss.xml"
    normalized = Feedbag.normalize_url(url)
    
    assert_match(/^https:\/\/www\.example\.jp\//, normalized)
    # Should not contain original Japanese characters
    refute_match(/日本語/, normalized)
    # Should contain percent-encoded version
    assert normalized.include?('%'), "URL should contain percent-encoded characters"
  end

  def test_normalize_hebrew_characters_in_url_path
    url = "https://www.example.co.il/עברית/feed/"
    normalized = Feedbag.normalize_url(url)
    
    assert_match(/^https:\/\/www\.example\.co\.il\//, normalized)
    # Should be percent-encoded
    refute_match(/עברית/, normalized)
  end

  def test_normalize_cyrillic_characters_in_url_path
    url = "https://www.example.ru/Русский/feed.xml"
    normalized = Feedbag.normalize_url(url)
    
    assert_match(/^https:\/\/www\.example\.ru\//, normalized)
    refute_match(/Русский/, normalized)
  end

  def test_normalize_arabic_characters_in_url_path
    url = "https://www.example.com/العربية/rss/"
    normalized = Feedbag.normalize_url(url)
    
    assert_match(/^https:\/\/www\.example\.com\//, normalized)
    refute_match(/العربية/, normalized)
  end

  def test_handle_already_ascii_urls_without_modification
    url = "https://www.example.com/feed/rss.xml"
    normalized = Feedbag.normalize_url(url)
    
    assert_equal url, normalized
  end

  def test_handle_already_encoded_urls
    # Already percent-encoded URL
    url = "https://www.example.com/path%20with%20spaces/feed.xml"
    normalized = Feedbag.normalize_url(url)
    
    # Should remain valid
    assert_match(/^https:\/\/www\.example\.com\//, normalized)
  end

  def test_handle_empty_url
    assert_equal "", Feedbag.normalize_url("")
  end

  def test_handle_nil_url
    assert_nil Feedbag.normalize_url(nil)
  end

  def test_handle_urls_with_query_parameters_containing_non_ascii
    url = "https://www.example.com/search?q=日本語&category=テスト"
    normalized = Feedbag.normalize_url(url)
    
    assert_match(/^https:\/\/www\.example\.com\/search\?/, normalized)
    # Query params should be encoded
    refute_match(/日本語/, normalized)
    refute_match(/テスト/, normalized)
  end

  def test_handle_urls_with_non_ascii_fragment
    url = "https://www.example.com/page#セクション"
    normalized = Feedbag.normalize_url(url)
    
    assert_match(/^https:\/\/www\.example\.com\/page/, normalized)
  end

  def test_normalized_url_is_valid_for_uri_parse
    urls = [
      "https://www.rehabsociety.org.hk/zh-hant/主頁/feed/",
      "https://www.example.jp/日本語/rss.xml",
      "https://www.example.co.il/עברית/feed/",
      "https://www.example.ru/Русский/feed.xml"
    ]
    
    urls.each do |url|
      normalized = Feedbag.normalize_url(url)
      # Should not raise URI::InvalidURIError
      assert_nothing_raised("URI.parse should work on normalized URL: #{url}") do
        URI.parse(normalized)
      end
    end
  end

  def test_find_does_not_raise_on_non_ascii_url
    # This test verifies that Feedbag.find doesn't raise URI::InvalidURIError
    # for non-ASCII URLs (the main issue #29)
    non_ascii_url = "https://www.rehabsociety.org.hk/zh-hant/主頁/feed/"
    
    # It should not raise an exception - just return empty or result
    assert_nothing_raised("Feedbag.find should not raise on non-ASCII URL") do
      # This will likely fail to connect, but should not raise URI::InvalidURIError
      begin
        Feedbag.find(non_ascii_url)
      rescue SocketError, Timeout::Error, OpenURI::HTTPError
        # These are expected for fake URLs
      end
    end
  end

  def test_feed_question_does_not_raise_on_non_ascii_url
    non_ascii_url = "https://www.example.org/中文/feed.rss"
    
    assert_nothing_raised("Feedbag.feed? should not raise on non-ASCII URL") do
      begin
        Feedbag.feed?(non_ascii_url)
      rescue SocketError, Timeout::Error, OpenURI::HTTPError
        # These are expected for fake URLs
      end
    end
  end
end

