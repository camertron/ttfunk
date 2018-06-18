module TTFunk
  class Table
    class Gpos
      class AnchorTable1 < TTFunk::SubTable
        attr_reader :format, :x_coordinate, :y_coordinate

        private

        def parse!
          @format, @x_coordinate, @y_coordinate = read(6, 'nnn')
          @length = 6
        end
      end
    end
  end
end
