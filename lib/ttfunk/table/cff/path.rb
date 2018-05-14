module TTFunk
  class Table
    class Cff < TTFunk::Table
      class Path
        attr_reader :commands

        def initialize
          @commands = []
        end

        def move_to(x, y)
          @commands << { type: :move, x: x, y: y }
        end

        def line_to(x, y)
          @commands << { type: :line, x: x, y: y }
        end

        def curve_to(x1, y1, x2, y2, x, y)
          @commands << {
            type: :curve,
            x1: x1,
            y1: y1,
            x2: x2,
            y2: y2,
            x: x,
            y: y
          }
        end

        def close_path
          @commands << { type: :close }
        end
      end
    end
  end
end
