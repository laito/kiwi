require 'yaml'

module Kiwi
  # Load configuration from a yaml file
  module Config
    extend self

    attr_reader :port, :nodes, :heartbeat_timeout, :replicas, :read_quorum
    attr_accessor :ip

    def init(args)
      config_file = args[0]
      config = YAML.load_file(File.join(__dir__, '../../' + config_file))
      @port = config['port']
      @nodes = config['nodes']
      @heartbeat_timeout = config['heartbeat_timeout']
      @replicas = config['replicas']
      @read_quorum = config['read_quorum']
    end
  end # module Config
end # module Kiwi
