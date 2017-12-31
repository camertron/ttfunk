module TTFunk
  class Table
    class Vorg < Table
      TAG = 'VORG'.freeze
      ENTRY_SIZE = 4
      HEADER_SIZE = 8

      attr_reader :major_version, :minor_version
      attr_reader :default_vert_origin_y, :count

      def for(glyph_id)
        @origins.fetch(glyph_id, default_vert_origin_y)
      end

      def tag
        TAG
      end

      def encode
        # @TODO
        raw
      end

      private

      def parse!
        @major_version, @minor_version = read(4, 'n*')
        @default_vert_origin_y = read_signed(1).first
        @count = read(2, 'n').first

        count.times do
          glyph_id = read(2, 'n').first
          vert_origin_y = read_signed(1).first
          origins[glyph_id] = vert_origin_y
        end
      end

      def origins
        @origins ||= {}
      end
    end
  end
end
