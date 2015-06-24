require 'kiwi'

module Kiwi
  # The main server which starts up the eventmachine listeners
  # TODO: Keep an event log
  class KiwiServer
    def start(args)
      load_config args
      add_members
      start_server
      trap(:INT) { EM.stop }
      trap(:TERM) { EM.stop }
    end

    def load_config(args)
      Config.init(args)
    end

    def add_members
      @db = Database::SimpleDatabase.new
      Membership.init(@db)
      Config.nodes.each do |node|
        Membership.add(node)
      end
    end

    def start_server
      EM.epoll
      EM.run do
        EM.add_periodic_timer(5) do
          Membership.heartbeat
        end
        EM.start_server('0.0.0.0', Config.port, Command::Receiver, @db)
      end
    end
  end # class KiwiServer
end # module Kiwi
