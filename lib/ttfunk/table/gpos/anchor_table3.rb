module TTFunk
  class Table
    class Gpos
      class AnchorTable3 < TTFunk::SubTable
        attr_reader :format, :x_coordinate, :y_coordinate
        attr_reader :x_device_offset, :y_device_offset

        def encode
          EncodedString.new do |result|
            result << [format, x_coordinate, y_coordinate].pack('n*')
            result << [x_device_offset, y_device_offset].pack('n*')
          end
        end

        private

        def parse!
          @format, @x_coordinate, @y_coordinate, @x_device_offset,
            @y_device_offset = read(10, 'n*')

          @length = 10
        end
      end
    end
  end
end
