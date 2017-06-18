require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha/setup'
require 'webmock/test_unit'
WebMock.allow_net_connect!

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'feedbag'
