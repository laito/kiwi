module Kiwi
  module Command
    # Server related command handlers
    # TODO: Add more commands (server info)
    module ServerCommand
      def command_quit(_args)
        close_connection
        ''
      end

      # Gossip!
      def command_psst(args)
        _, ip = Socket.unpack_sockaddr_in(get_peername)
        port = args[1]
        node = "#{ip}:#{port}"
        @ring.update(node)
        'OK'
      end
    end # module ServerCommand
  end # module Command
end # module Kiwi
