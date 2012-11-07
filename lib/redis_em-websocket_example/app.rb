require 'em-websocket'
require File.expand_path('../config/initializers/configurations.rb', __FILE__)
require File.expand_path('../config/initializers/establish_connection.rb', __FILE__)
require File.expand_path('../config/initializers/redis.rb', __FILE__)
require File.expand_path('../handler.rb', __FILE__)

@sockets = {} # ws: username

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
        init_ws(ws)
      end

      ws.onclose do
        @sockets.delete ws
        puts "o#{@sockets.values.select{|u| u}.size} s#{@sockets.size}"
      end

      ws.onmessage do |evt|
        handle(ws, evt)
      end

      ws.onerror do |error|
      end
    end
  end
end

sleep
