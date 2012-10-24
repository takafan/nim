require 'redis'
require 'yajl'

# puts Yajl::Encoder.encode([{ 
#   channel: 'syspop',
#   say: 'Something witty'
# }, { 
#   channel: 'syspop2',
#   say: 'Something witty2'
# }])

@db1 = Redis.new(host: '192.168.3.220', port: 6379, password: 'jredis123456')

msg = { 
  channel: 'syspop',
  say: 'Something witty'
}

@db1.publish ARGV.shift || 's1', Yajl::Encoder.encode(msg)
