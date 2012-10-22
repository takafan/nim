require 'redis'
require 'yajl'

@redis = Redis.new(host: '192.168.3.220', port: 6379, password: 'jredis123456')
@redis.publish 'ws', Yajl::Encoder.encode({
  content: 'Something witty',
  channel: 'c1'
})
