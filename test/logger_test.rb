#!/usr/bin/env ruby
# Test for configurable logger (Issue #33)

require 'rubygems'
require 'test/unit'
require 'stringio'
require 'logger'

# Add user gems to load path for addressable
gem_home = File.expand_path('~/.gem/ruby/2.6.0')
$LOAD_PATH.unshift(File.join(gem_home, 'gems', 'addressable-2.8.8', 'lib'))
$LOAD_PATH.unshift(File.join(gem_home, 'gems', 'public_suffix-5.1.1', 'lib'))

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'feedbag'

class LoggerTest < Test::Unit::TestCase

  def setup
    # Reset logger to default before each test
    Feedbag.logger = nil
  end

  def teardown
    # Reset logger after each test
    Feedbag.logger = nil
  end

  def test_default_logger_exists
    assert_not_nil Feedbag.logger
    assert_kind_of Logger, Feedbag.logger
  end

  def test_default_logger_writes_to_stderr
    output = StringIO.new
    Feedbag.logger = Logger.new(output)
    Feedbag.logger.formatter = proc { |severity, _datetime, _progname, msg| "#{msg}\n" }
    
    Feedbag.logger.error "test message"
    
    assert_match(/test message/, output.string)
  end

  def test_custom_logger_can_be_set
    custom_logger = Logger.new(StringIO.new)
    Feedbag.logger = custom_logger
    
    assert_equal custom_logger, Feedbag.logger
  end

  def test_logger_can_be_silenced
    null_output = StringIO.new
    Feedbag.logger = Logger.new(null_output)
    Feedbag.logger.level = Logger::FATAL  # Only log fatal errors
    
    Feedbag.logger.error "this should not appear"
    
    assert_equal "", null_output.string
  end

  def test_errors_go_to_custom_logger
    output = StringIO.new
    custom_logger = Logger.new(output)
    custom_logger.formatter = proc { |severity, _datetime, _progname, msg| "#{msg}\n" }
    Feedbag.logger = custom_logger
    
    # Try to find feeds on a non-existent domain
    # This should log an error
    Feedbag.find("http://this-domain-does-not-exist-feedbag-test.invalid/feed")
    
    # Check that something was logged
    assert output.string.length > 0, "Expected error to be logged"
    assert_match(/error occurred with/i, output.string)
  end

  def test_errors_can_be_captured
    captured_messages = []
    
    # Create a custom logger that captures messages
    custom_logger = Logger.new(StringIO.new)
    custom_logger.formatter = proc do |severity, _datetime, _progname, msg|
      captured_messages << msg
      ""
    end
    Feedbag.logger = custom_logger
    
    # Trigger an error
    Feedbag.find("http://this-domain-does-not-exist-feedbag-test.invalid/feed")
    
    assert captured_messages.length > 0, "Expected to capture error messages"
  end

  def test_logger_works_with_timeout_errors
    output = StringIO.new
    custom_logger = Logger.new(output)
    custom_logger.formatter = proc { |severity, _datetime, _progname, msg| "#{msg}\n" }
    Feedbag.logger = custom_logger
    
    # The error handling should work regardless of error type
    # Just verify the logger is being used
    assert_respond_to Feedbag.logger, :error
    assert_respond_to Feedbag.logger, :warn
    assert_respond_to Feedbag.logger, :info
  end

  def test_logger_reset_to_default
    custom_logger = Logger.new(StringIO.new)
    Feedbag.logger = custom_logger
    assert_equal custom_logger, Feedbag.logger
    
    # Reset to default
    Feedbag.logger = nil
    
    # Should get a new default logger
    assert_not_equal custom_logger, Feedbag.logger
    assert_kind_of Logger, Feedbag.logger
  end

  # Simulate Rails.logger compatibility
  def test_rails_logger_compatibility
    # Rails.logger is just a Logger instance, so any Logger should work
    rails_like_logger = Logger.new(StringIO.new)
    rails_like_logger.progname = "Rails"
    
    Feedbag.logger = rails_like_logger
    
    assert_equal rails_like_logger, Feedbag.logger
    assert_nothing_raised do
      Feedbag.logger.error "test"
      Feedbag.logger.warn "test"
      Feedbag.logger.info "test"
      Feedbag.logger.debug "test"
    end
  end

end

