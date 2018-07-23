require_relative '../table'

module TTFunk
  class Table
    class Hhea < Table
      attr_reader :version
      attr_reader :ascent
      attr_reader :descent
      attr_reader :line_gap
      attr_reader :advance_width_max
      attr_reader :min_left_side_bearing
      attr_reader :min_right_side_bearing
      attr_reader :x_max_extent
      attr_reader :carot_slope_rise
      attr_reader :carot_slope_run
      attr_reader :caret_offset
      attr_reader :metric_data_format
      attr_reader :number_of_metrics

      class << self
        def encode(hhea, hmtx, mapping)
          min_max = min_max_values_for(hhea, mapping)

          ''.tap do |table|
            table << [hhea.version].pack('N')
            table << [
              hhea.ascent, hhea.descent, hhea.line_gap,
              min_max[:advance_width_max], min_max[:min_lsb],
              min_max[:min_rsb], min_max[:x_max_extent], hhea.carot_slope_rise,
              hhea.carot_slope_run, hhea.caret_offset,
              0, 0, 0, 0, hhea.metric_data_format, hmtx[:number_of_metrics]
            ].pack('n*')
          end
        end

        private

        def min_max_values_for(hhea, mapping)
          aw_max = 0
          min_lsb = Float::INFINITY
          min_rsb = Float::INFINITY
          x_max_ex = -Float::INFINITY

          mapping.each do |_, old_glyph_id|
            hm = hhea.file.horizontal_metrics.for(old_glyph_id)
            next unless hm
            aw_max = hm.advance_width if aw_max < hm.advance_width

            glyph = if hhea.file.cff.exists?
                      hhea.file
                          .cff
                          .top_index[0]
                          .charstrings_index[old_glyph_id]
                          .glyph
                    else
                      hhea.file.glyph_outlines.for(old_glyph_id)
                    end

            next if glyph.nil?
            next if glyph.number_of_contours == 0

            min_lsb = hm.left_side_bearing if min_lsb > hm.left_side_bearing

            rsb = hm.advance_width -
              hm.left_side_bearing -
              (glyph.x_max - glyph.x_min)

            min_rsb = rsb if min_rsb > rsb

            extent = hm.left_side_bearing + (glyph.x_max - glyph.x_min)
            x_max_ex = extent if extent > x_max_ex
          end

          {
            advance_width_max: aw_max,
            min_lsb: infinity_to_zero(min_lsb),
            min_rsb: infinity_to_zero(min_rsb),
            x_max_extent: infinity_to_zero(x_max_ex)
          }
        end

        def infinity_to_zero(num)
          return num unless num.respond_to?(:infinite?)
          num.infinite? ? 0 : num
        end
      end

      private

      def parse!
        @version = read(4, 'N').first
        @ascent, @descent, @line_gap = read_signed(3)
        @advance_width_max = read(2, 'n').first

        @min_left_side_bearing, @min_right_side_bearing, @x_max_extent,
          @carot_slope_rise, @carot_slope_run, @caret_offset,
          _reserved, _reserved, _reserved, _reserved,
          @metric_data_format = read_signed(11)

        @number_of_metrics = read(2, 'n').first
      end
    end
  end
end
