module TTFunk
  class Table
    class Gpos
      class AnchorTable1 < TTFunk::SubTable
        attr_reader :format, :x_coordinate, :y_coordinate

        def encode
          EncodedString.new do |result|
            result << [format, x_coordinate, y_coordinate].pack('n*')
          end
        end

        private

        def parse!
          @format, @x_coordinate, @y_coordinate = read(6, 'n*')
          @length = 6
        end
      end
    end
  end
end
