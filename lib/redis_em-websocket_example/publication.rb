require File.expand_path('../app.rb', __FILE__)

# puts Yajl::Encoder.encode([{ 
#   channel: 'syspop',
#   say: 'Something witty'
# }, { 
#   channel: 'syspop2',
#   say: 'Something witty2'
# }])

@redis = Redis.new(host: '192.168.3.220', port: 6379, password: 'jredis123456')

msg = { 
  channel: 'syspop',
  say: 'Something witty'
}

@redis.publish ARGV.shift || 's1', Yajl::Encoder.encode(msg)
