require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha/setup'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'feedbag'