require 'faye'
require 'eventmachine'

EM.run do
  client = Faye::Client.new('http://localhost:3000/faye')

  client.publish('/foo', 'text' => 'Hello world')
end
