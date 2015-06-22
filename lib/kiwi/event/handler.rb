require 'eventmachine'

module Kiwi
  module Event
    # This is the main handler class which deals with eventmachine
    # It sends and receives lines, and passes it on to the command receiver
    class Handler < EventMachine::Connection
      include EM::Protocols::LineText2
      def initialize(database, ring)
        @port, @ip = Socket.unpack_sockaddr_in(get_sockname)
        @db = database
        @ring = ring
        @connected = true
      end

      def post_init
        send_data '$ '
      end

      def receive_line(data)
        return unless @connected
        data = dispatcher(data.split(' '))
        return unless data.is_a? String
        send_line data
      end

      def send_line(data)
        send_data "$ #{data}"
        send_data "\r\n"
        send_data '$ '
      end

      def unbind
        @connected = false
      end
    end # class Handler < EventMachine::Connection
  end # module Event
end # module Kiwi
