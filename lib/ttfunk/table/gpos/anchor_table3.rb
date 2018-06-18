module TTFunk
  class Table
    class Gpos
      class AnchorTable3 < TTFunk::SubTable
        attr_reader :format, :x_coordinate, :y_coordinate
        attr_reader :x_device_offset, :y_device_offset

        private

        def parse!
          @format, @x_coordinate, @y_coordinate, @x_device_offset,
            @y_device_offset = read(10, 'n5')

          @length = 10
        end
      end
    end
  end
end
