require 'kiwi/command/receiver'
require 'kiwi/config'
require 'kiwi/database/simple_db'
require 'kiwi/membership/membership'

module Kiwi
  # The main server which starts up the eventmachine listeners
  # TODO: Keep an event log
  class KiwiServer
    def start(args)
      load_config args
      setup_ring
      start_server
    end

    def load_config(args)
      @config = Kiwi::Config::KiwiConfig.new(args)
    end

    def setup_ring
      @db = Kiwi::Database::SimpleDatabase.new
      @ring = Kiwi::Membership::Ring.new(@db)
      @config.nodes.each do |node|
        @ring.add(node)
      end
    end

    def start_server
      receiver = Kiwi::Command::Receiver
      EM.epoll
      EM.run do
        EM.add_periodic_timer(5) do
          @ring.heartbeat @config.heartbeat_timeout, @config.port
        end
        EM.start_server('0.0.0.0', @config.port, receiver, @db, @ring)
      end
    end
  end # class KiwiServer
end # module Kiwi
