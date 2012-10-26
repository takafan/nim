require 'redis'
require File.expand_path('../configurations.rb', __FILE__)

@redis = Redis.new(@configurations['redis'])
