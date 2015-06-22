require 'kiwi/event/handler'
require 'kiwi/command/database_command'
require 'kiwi/command/server_command'
require 'kiwi/messaging/messenger'

module Kiwi
  module Command
    # Untangled from Eventmachine code, receiver handles commands
    # Commands include - database and server commands
    class Receiver < Kiwi::Event::Handler
      include DatabaseCommand
      include ServerCommand

      # list of commands which are allowed
      def initialize(database, ring)
        super(database, ring)
        @valid_methods = DatabaseCommand.public_instance_methods
        @valid_methods << ServerCommand.public_instance_methods
        @valid_methods = @valid_methods.flatten
      end

      def dispatcher(data)
        return '' if data.empty? || data.nil?
        method = "command_#{data[0]}".intern
        return 'Error: Command not found.' unless @valid_methods.include? method
        send(method, data)
      rescue RemoteError => e
        dispatch_to_remote(data, e.message)
      rescue ArgumentError => e
        e.message
      rescue KeyError
        'Error: Key not found'
      end

      def dispatch_to_remote(data, server)
        # Key is not stored locally
        Kiwi::Messaging::Messenger.send_message(
          data,
          server,
          proc do |line|
            send_line(line)
          end
        )
      end
    end # class Receiver < Event::Handler
  end # module Command
end # module Kiwi
