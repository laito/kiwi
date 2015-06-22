module Kiwi
  module Database
    # A simple database implementation which using a hash
    # TODO Background saving of the in-memory data
    class SimpleDatabase
      def initialize
        @db = {}
      end

      def get(key)
        @db.fetch(key)
      end

      def set(key, value)
        @db.store(key, value)
      end

      def del(key)
        @db.delete(key) || '0'
      end

      def each
        @db.each do |key, value|
          yield key, value
        end
      end
    end # class SimpleDatabase
  end # module Database
end # module Kiwi
