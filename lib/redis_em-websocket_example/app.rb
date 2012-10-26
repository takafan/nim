require 'em-websocket'
require File.expand_path('../config/initializers/configurations.rb', __FILE__)
require File.expand_path('../config/initializers/establish_connection.rb', __FILE__)
require File.expand_path('../config/initializers/redis.rb', __FILE__)
require File.expand_path('../handler.rb', __FILE__)

@sockets = {} # wskey: ws
@onlines = {} # wskey: login

include Handler

Thread.new do
  @redis.subscribe('syspop') do |on|
    on.message do |s, msg|
      @sockets.each {|key, sock| sock.send syspop(msg)}
    end
  end
end

Thread.new do
  EventMachine.run do
    ws_conf = @configurations['ws']
    EventMachine::WebSocket.start(host: ws_conf['host'], port: ws_conf['port'], debug: ARGV.shift == 'debug') do |ws|
      ws.onopen do
        @sockets[ws.request['sec-websocket-key']] = ws
        puts "s#{@sockets.size}"
        ws.send greeting
      end

      ws.onclose do
        @onlines.delete ws.request['sec-websocket-key']
        @sockets.delete ws.request['sec-websocket-key']
        puts "o#{@onlines.size} s#{@sockets.size}"
      end

      ws.onmessage do |evt|
        puts "Recieved message: #{evt}"
        res = handle(ws.request['sec-websocket-key'], evt)
        puts "Sending message: #{res}"
        ws.send res
      end

      ws.onerror do |error|
      end
    end
  end
end

sleep
