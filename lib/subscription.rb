require 'faye'
require 'eventmachine'

EM.run do
  client = Faye::Client.new('http://localhost:5959/faye')

  client.subscribe('/foo') do |message|
    puts message.inspect
  end
end
