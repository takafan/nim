require 'redis'
@redis = Redis.new(host: '192.168.3.220', port: 6379, password: 'jredis123456')
@redis.publish 'ws', 'Something witty'
