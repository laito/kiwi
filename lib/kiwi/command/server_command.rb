require 'kiwi/membership/membership'

module Kiwi
  module Command
    # Server related command handlers
    # TODO: Add more commands (server info)
    module ServerCommand
      def command_quit(_args)
        close_connection
        ''
      end

      def command_shutdown(_args)
        EM.stop
      end

      # Gossip!
      def command_psst(args)
        _, ip = Socket.unpack_sockaddr_in(get_peername)
        port = args[1]
        node = "#{ip}:#{port}"
        Membership.update(node)
        'OK'
      end
    end # module ServerCommand
  end # module Command
end # module Kiwi
