require 'faye'
require 'eventmachine'

EM.run do
  client = Faye::Client.new('http://localhost:5959/faye')

  client.publish('/foo', 'text' => 'Hello world')
end
