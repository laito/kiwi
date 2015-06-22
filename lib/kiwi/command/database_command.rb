module Kiwi
  module Command
    # Database related command handlers
    module DatabaseCommand
      # A custom exception raised when setting a remote key
      # Remote key is one which is supposed to be on a different server
      class RemoteError < StandardError
      end

      def key_local?(key)
        @ring.node_for(key).eql? "#{@ip}:#{@port}"
      end

      def command_set(args)
        fail ArgumentError, 'Wrong number of arguments' if args.count != 3
        if key_local? args[1]
          @db.set(args[1], args[2])
        else
          fail RemoteError, @ring.node_for(args[1])
        end
      end

      def command_get(args)
        fail ArgumentError, 'Wrong number of arguments' if args.count != 2
        if key_local? args[1]
          @db.get(args[1])
        else
          fail RemoteError.new, @ring.node_for(args[1])
        end
      end

      def command_del(args)
        fail ArgumentError, 'Wrong number of arguments' if args.count != 2
        if key_local? args[1]
          @db.del(args[1])
        else
          fail RemoteError.new, @ring.node_for(args[1])
        end
      end
    end # module DatabaseCommand
  end # module Command
end # module Kiwi
