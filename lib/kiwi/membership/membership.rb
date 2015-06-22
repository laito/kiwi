  require 'zlib'

  module Kiwi
    module Membership
      # A very simple implementation of consistent hashing using Ruby Hashes
      # It also serves as the storage for membership table
      # TODO: Implement something better than all-to-all heartbeating protocol
      # TODO: Handle node failures
      # TODO: Use a better data structure for the hash ring
      class Ring
        def initialize(db, replicas = 3)
          @ring = {}
          @db = db
          @members = {}
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

        def node_for(key)
          key_hash = hash(key)
          return @ring[key_hash] if @ring[key_hash]
          server_hash = @ring.keys.select { |k| k > key_hash }.sort.first
          return @ring.first.last if server_hash.nil? # No keys > key_hash
          @ring[server_hash]
        end

        def update(server)
          @members.store(server, Time.now)
        end

        def heartbeat(timeout, port)
          message = ["psst #{port}"]
          @members.each do |node, value|
            # remove the node if it hasn't responded since the timeout
            if (Time.now - value) > timeout
              delete node
            else
              # send a heartbeat message to the node if its still up
              Kiwi::Messaging::Messenger.send_message(message, node, nil)
            end
          end
        end

        def refresh_db
          @db.each do |key, value|
            puts key, value
            server = node_for(key)
            data = ['set', key, value]
            Kiwi::Messaging::Messenger.send_message(data, server, nil)
          end
        end

        protected

        def hash(key)
          Zlib.crc32("#{key}")
        end
      end # class Ring
    end # module ConsistentHashing
  end # module Kiwi
