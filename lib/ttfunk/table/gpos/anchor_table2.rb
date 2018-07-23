module TTFunk
  class Table
    class Gpos
      class AnchorTable2 < TTFunk::SubTable
        attr_reader :format, :x_coordinate, :y_coordinate, :anchor_point

        def encode
          EncodedString.new do |result|
            result << [format, x_coordinate, y_coordinate, anchor_point].pack('n*')
          end
        end

        private

        def parse!
          @format, @x_coordinate, @y_coordinate, @anchor_point = read(8, 'n*')
          @length = 8
        end
      end
    end
  end
end
