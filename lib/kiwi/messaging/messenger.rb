require 'socket'
require 'fiber'
require 'em-synchrony'

module Kiwi
  # Responsible for communication between the nodes
  module Messenger
    extend self

    # The eventmachine handler which sends/receives data
    class Message < EventMachine::Connection
      def initialize(data, callback)
        @callback = callback
        @data = data
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

    def send_message(nodes, data, callback)
      nodes.delete("#{Config.ip}:#{Config.port}") # Don't send message to self
      EM.run do
        nodes.each do |node|
          host, port = node.split(':')
          EM.connect host, port, Message, data, callback
        end
      end
    end

    def set(key, value, callback)
      data = "set #{key} #{value} false\r\n"
      nodes = Membership.nodes_for(key)
      send_message(nodes, data, callback)
    end

    def get(key, callback)
      data = "get #{key} false\r\n"
      nodes = Membership.nodes_for(key)
      send_message(nodes, data, callback)
    end

    def del(key, callback)
      data = "del #{key} false\r\n"
      nodes = Membership.nodes_for(key)
      send_message(nodes, data, callback)
    end
  end # module Messaging
end # module Kiwi
