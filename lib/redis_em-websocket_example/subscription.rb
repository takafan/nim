require 'redis'
require 'em-websocket'
require File.expand_path('../auth.rb', __FILE__)
require File.expand_path('../handler.rb', __FILE__)

include Handler

@db1 = Redis.new(host: '192.168.3.220', port: 6379, password: 'jredis123456')

@host_and_ports = {
  s1: %w(0.0.0.0 8081),
  s2: %w(0.0.0.0 8082)
}

@sockets = {
  s1: {},
  s2: {}
}


Thread.new do
  @db1.subscribe(@sockets.keys) do |on|
    on.message do |s, msg|
      puts "#{s} sending message: #{msg}"
      @sockets[s.to_sym].each {|key, sock| sock.send msg}
    end
  end
end

@host_and_ports.each do |s, host_and_port|
  Thread.new do
    EventMachine.run do
      EventMachine::WebSocket.start(host: host_and_port.first, port: host_and_port.last) do |ws|

        ws.onopen do
          @sockets[s.to_sym][ws.request['sec-websocket-key']] = ws
          puts "#{s} #{@sockets[s.to_sym].size}"
        end

        ws.onclose do
          @sockets[s.to_sym].delete ws.request['sec-websocket-key']
          puts "#{s} #{@sockets[s.to_sym].size}"
        end

        ws.onmessage do |msg|
          puts "Recieved message: #{msg}"
          res = handle(msg)
          puts res
          ws.send res
        end
      end
    end
  end
end

sleep
