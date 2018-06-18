module TTFunk
  class Table
    class Gpos
      class AnchorTable2 < TTFunk::SubTable
        attr_reader :format, :x_coordinate, :y_coordinate, :anchor_point

        private

        def parse!
          @format, @x_coordinate, @y_coordinate, @anchor_point = read(8, 'n4')
          @length = 8
        end
      end
    end
  end
end
