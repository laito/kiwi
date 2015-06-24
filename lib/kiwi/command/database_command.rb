require 'kiwi/membership/membership'
require 'kiwi/messaging/messenger'
require 'kiwi/config'

module Kiwi
  module Command
    # Database related command handlers
    module DatabaseCommand
      # A custom exception raised when setting a remote key
      # Remote key is one which is supposed to be on a different server
      class RemoteError < StandardError
      end

      def key_local?(key)
        Membership.nodes_for(key).include? "#{Config.ip}:#{Config.port}"
      end

      def command_set(args)
        fail ArgumentError, 'Wrong number of arguments' if args.count != 3 && args.count != 4
        @db.set(args[1], args[2]) if key_local? args[1]
        Messenger.set(args[1], args[2], nil) unless args[3].eql? 'false'
        args[2]
      end

      def command_get(args)
        fail ArgumentError, 'Wrong number of arguments' if args.count != 2 && args.count != 3
        unless args[2].eql? 'false'
          Membership.quorum[args[1]] = [] # Set up the quorum container
          Membership.quorum[args[1]] << @db.get(args[1]) if key_local? args[1]
          Messenger.get(args[1],
                        lambda do |line|
                          return if Membership.quorum[args[1]].nil?
                          Membership.quorum[args[1]] << line
                          if Membership.quorum[args[1]].count >= Config.read_quorum
                            send_line(line)
                            Membership.quorum.delete(args[1])
                          end
                        end)
        else
          @db.get(args[1])
        end
      end

      def command_del(args)
        fail ArgumentError, 'Wrong number of arguments' if args.count != 2 && args.count != 3
        @db.del(args[1]) if key_local? args[1]
        Messenger.del(args[1], nil) unless args[2].eql? 'false'
        'done'
      end
    end # module DatabaseCommand
  end # module Command
end # module Kiwi
