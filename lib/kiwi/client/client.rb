module Kiwi
  module Client
    # A TCPSocket based client to perform basic operations
    # Operations include: setting, getting and deleting keys
    class TCPClient
      def initialize(host, port)
        @sock = TCPSocket.new(host, port)
      end

      def set(key, value)
        @sock.puts("set #{key} #{value}")
        @sock.recv(256)
      end

      def get(key)
        @sock.puts("get #{key}")
        @sock.recv(256)
      end

      def del(key)
        @sock.puts("del #{key}")
        @sock.recv(256)
      end
    end
  end
end
