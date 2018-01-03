require_relative '../table'

module TTFunk
  class Table
    class Gpos < TTFunk::Table
      TAG = 'GPOS'.freeze

      def self.encode
        # @TODO
        raw
      end

      def tag
        TAG
      end

      private

      def parse!
        # @TODO
      end
    end
  end
end
