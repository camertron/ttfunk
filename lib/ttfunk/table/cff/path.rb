module TTFunk
  class Table
    class Cff < TTFunk::Table
      class Path
        CLOSE_PATH_CMD = [:close].freeze

        attr_reader :commands

        def initialize
          @commands = []
        end

        # rubocop:disable Naming/UncommunicativeMethodParamName
        def move_to(x, y)
          @commands << [:move, x, y]
        end

        def line_to(x, y)
          @commands << [:line, x, y]
        end

        def curve_to(x1, y1, x2, y2, x, y)
          @commands << [:curve, x1, y1, x2, y2, x, y]
        end

        def close_path
          @commands << CLOSE_PATH_CMD
        end

        def number_of_contours
          # contours must be closed
          commands.count { |cmd| cmd[0] == :close }
        end

        def to_svg
          path_data = commands.map do |command|
            case command[0]
            when :move
              "M#{format_values(command, :x, :y)}"
            when :line
              "L#{format_values(command, :x, :y)}"
            when :curve
              "C#{format_values(command, :x1, :y1, :x2, :y2, :x, :y)}"
            when :close
              'Z'
            end
          end.join(' ')

          "<path d=\"#{path_data}\"/>"
        end

        def render(x: 0, y: 0, font_size: 72, units_per_em: 1000)
          new_path = self.class.new
          scale = 1.0 / units_per_em * font_size

          commands.each do |cmd|
            case cmd[:type]
            when :move
              new_path.move_to(x + (cmd[:x] * scale), y + (-cmd[:y] * scale))
            when :line
              new_path.line_to(x + (cmd[:x] * scale), y + (-cmd[:y] * scale))
            when :curve
              new_path.curve_to(
                x + (cmd[:x1] * scale),
                y + (-cmd[:y1] * scale),
                x + (cmd[:x2] * scale), y + (-cmd[:y2] * scale),
                x + (cmd[:x] * scale), y + (-cmd[:y] * scale)
              )
            when :close
              new_path.close_path
            end
          end

          new_path
        end
        # rubocop:enable Naming/UncommunicativeMethodParamName

        private

        def format_values(command, *keys)
          keys.map { |k| format('%.2f', command[k]) }.join(' ')
        end
      end
    end
  end
end
