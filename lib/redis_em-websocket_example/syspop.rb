require File.expand_path('../config/redis.rb', __FILE__)

message = ARGV.shift

@redis.publish('syspop', message) if message
