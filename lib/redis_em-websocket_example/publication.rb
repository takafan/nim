require 'redis'
require 'yajl'

@db1 = Redis.new(host: '192.168.3.220', port: 6379, password: 'jredis123456')

msg = { 
  channel: 'chat1',
  who: 'radio',
  say: 'Something witty'
}

@db1.publish ARGV.shift || 's1', Yajl::Encoder.encode(msg)
