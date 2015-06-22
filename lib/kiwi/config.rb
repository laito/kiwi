require 'yaml'

module Kiwi
  module Config
    # Load configuration from a yaml file
    class KiwiConfig
      attr_reader :port, :nodes, :heartbeat_timeout

      def initialize(args)
        config_file = args[0]
        config = YAML.load_file(File.join(__dir__, '../../' + config_file))
        @port = config['port']
        @nodes = config['nodes']
        @heartbeat_timeout = config['heartbeat_timeout']
      end
    end # class KiwiConfig
  end # module Config
end # module Kiwi
