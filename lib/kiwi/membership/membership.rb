require 'zlib'
require 'kiwi/config'

module Kiwi
  # A very simple implementation of consistent hashing using Ruby Hashes
  # It also serves as the storage for membership table
  # TODO: Implement something better than all-to-all heartbeating protocol
  # TODO: Handle node failures
  # TODO: Use a better data structure for the hash ring
  module Membership
    extend self

    attr_accessor :quorum

    def init(db, replicas = 1000)
      @ring = {}
      @db = db
      @members = {}
      @quorum = {}
      @replicas = replicas
    end

    def length
      @ring.length
    end

    def add(server)
      @members.store(server, Time.now)
      @replicas.times do |i|
        @ring[hash("#{server}_#{i}")] = server
      end
      refresh_db
    end

    def delete(server)
      @members.delete(server)
      @replicas.times do |i|
        @ring.delete("#{server}_#{i}")
      end
      refresh_db
    end

    def nodes_for(key)
      key_hash = hash(key)
      server_hashes = @ring.keys.select { |k| k >= key_hash }.sort
      servers = @ring.values_at(*server_hashes)
      servers = servers.uniq.first(Config.replicas)
      return @ring.values.uniq.first(Config.replicas) if servers.empty? # No keys > key_hash
      if servers.count < Config.replicas
        servers += @ring.values.uniq.first(Config.replicas - server_hashes.count)
      end
      servers
    end

    def update(server)
      @members.store(server, Time.now)
    end

    def heartbeat
      message = "psst #{Config.port}"
      @members.each do |node, value|
        # remove the node if it hasn't responded since the timeout
        if (Time.now - value) > Config.heartbeat_timeout
          delete node
        else
          # send a heartbeat message to the node if its still up
          Messenger.send_message([node], message, nil)
        end
      end
    end

    def refresh_db
      @db.each do |key, value|
        nodes = nodes_for(key)
        data = "set #{key} #{value}"
        Messenger.send_message(nodes, data, nil)
      end
    end

    def hash(key)
      Zlib.crc32("#{key}")
    end
  end # module ConsistentHashing
end # module Kiwi
