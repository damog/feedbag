require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'feedbag'

# Optional test dependencies - only loaded if available
begin
  require 'shoulda'
rescue LoadError
  # shoulda not available
end

begin
  require 'mocha/setup'
rescue LoadError
  # mocha not available
end

begin
  require 'webmock/test_unit'
  WebMock.allow_net_connect!
rescue LoadError
  # webmock not available
end
