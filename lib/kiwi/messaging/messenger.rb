require 'socket'
require 'fiber'
require 'em-synchrony'

module Kiwi
  module Messaging
    # Responsible for communication between the nodes
    class Messenger
      # The eventmachine handler which sends/receives data
      class Message < EventMachine::Connection
        def initialize(data, callback)
          @callback = callback
          @data = "#{data.join(' ')}\r\n"
        end

        def post_init
          @data_sent = false
        end

        def receive_data(data)
          @response = data.split(' ', 2).last.split("\n").first if @data_sent
          send_data @data unless @data_sent
          @data_sent = true
          @callback.call(@response) if @response && @callback
        end
      end # class Message

      def self.send_message(data, server, callback)
        host, port =  server.split(':')
        EM.run do
          EM.connect host, port, Message, data, callback
        end
      end
    end # class Messenger
  end # module Messaging
end # module Kiwi
