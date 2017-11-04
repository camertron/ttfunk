module TTFunk
  class Table
    class Glyf
      class PathBased
        attr_reader :path, :horizontal_metrics

        def initialize(path, horizontal_metrics)
          @path = path
          @horizontal_metrics = horizontal_metrics
        end

        def metrics
          @metrics ||= begin
            metrics = {
              x_min: x_coords.min || 0,
              y_min: y_coords.min || 0,
              x_max: x_coords.max || horizontal_metrics.advance_width,
              y_max: y_coords.max || 0,
              left_side_bearing: horizontal_metrics.left_side_bearing
            }

            x_diff = metrics[:x_max] - metrics[:x_min]
            metrics[:right_side_bearing] = horizontal_metrics.advance_width - metrics[:left_side_bearing] - x_diff

            metrics
          end
        end

        def x_coords
          coords.first
        end

        def y_coords
          coords.last
        end

        def coords
          @coords ||= begin
            x_coords = []
            y_coords = []

            path.commands.each do |command|
              type = command[:type]

              if type != :close
                x_coords << command[:x]
                y_coords << command[:y]
              end

              if type == :quad || type == :curve
                x_coords << command[:x1]
                y_coords << command[:y1]
              end

              if type == :curve
                x_coords << command[:x2]
                y_coords << command[:y2]
              end
            end

            [x_coords, y_coords]
          end
        end
      end
    end
  end
end
