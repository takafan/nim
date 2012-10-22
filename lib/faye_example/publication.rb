require 'faye'
require 'eventmachine'

EM.run do
  client = Faye::Client.new('http://localhost:5959/faye')

  client.publish('/foo', content: 'Hello world', channel: 'c1')
end
