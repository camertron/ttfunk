# frozen_string_literal: true

require_relative '../table'

module TTFunk
  class Table
    class Maxp < Table
      DEFAULT_MAX_COMPONENT_DEPTH = 1

      attr_reader :version
      attr_reader :num_glyphs
      attr_reader :max_points
      attr_reader :max_contours
      attr_reader :max_component_points
      attr_reader :max_component_contours
      attr_reader :max_zones
      attr_reader :max_twilight_points
      attr_reader :max_storage
      attr_reader :max_function_defs
      attr_reader :max_instruction_defs
      attr_reader :max_stack_elements
      attr_reader :max_size_of_instructions
      attr_reader :max_component_elements
      attr_reader :max_component_depth

      class << self
        def encode(maxp, new2old_glyph)
          ''.b.tap do |table|
            num_glyphs = new2old_glyph.length
            table << [maxp.version, num_glyphs].pack('Nn')

            if maxp.version == 0x10000
              stats = stats_for(
                maxp, glyphs_from_ids(maxp, new2old_glyph.values)
              )

              table << [
                stats[:max_points].value_or(0),
                stats[:max_contours].value_or(0),
                stats[:max_component_points].value_or(0),
                stats[:max_component_contours].value_or(0),
                # these all come from the fpgm and cvt tables, which
                # we don't support at the moment
                maxp.max_zones,
                maxp.max_twilight_points,
                maxp.max_storage,
                maxp.max_function_defs,
                maxp.max_instruction_defs,
                maxp.max_stack_elements,
                stats[:max_size_of_instructions].value_or(0),
                stats[:max_component_elements].value_or(0),
                stats[:max_component_depth].value_or(0)
              ].pack('n*')
            end
          end
        end

        private

        def glyphs_from_ids(maxp, glyph_ids)
          glyph_ids.each_with_object([]) do |glyph_id, ret|
            if (glyph = maxp.file.glyph_outlines.for(glyph_id))
              ret << glyph
            end
          end
        end

        def stats_for(maxp, glyphs)
          stats_for_simple(maxp, glyphs).merge(
            stats_for_compound(maxp, glyphs)
          )
        end

        def stats_for_simple(_maxp, glyphs)
          Hash.new { |h, k| h[k] = Max.new }.tap do |simple_stats|
            glyphs.each do |glyph|
              if glyph.compound?
                simple_stats[:max_component_elements] << glyph.glyph_ids.size
              else
                simple_stats[:max_points] << glyph.end_point_of_last_contour
                simple_stats[:max_contours] << glyph.number_of_contours
                simple_stats[:max_size_of_instructions] <<
                  glyph.instruction_length
              end
            end
          end
        end

        def stats_for_compound(maxp, glyphs)
          Hash.new { |h, k| h[k] = Max.new }.tap do |compound_stats|
            glyphs.each do |glyph|
              next unless glyph.compound?
              stats = totals_for_compound(maxp, [glyph], 0)
              compound_stats[:max_component_points] << stats[:total_points]
              compound_stats[:max_component_contours] << stats[:total_contours]
              compound_stats[:max_component_depth] << stats[:max_depth]
            end
          end
        end

        def totals_for_compound(maxp, glyphs, depth)
          total_points = Sum.new
          total_contours = Sum.new
          max_depth = Max.new(depth)

          glyphs.each do |glyph|
            if glyph.compound?
              stats = totals_for_compound(
                maxp, glyphs_from_ids(maxp, glyph.glyph_ids), depth + 1
              )

              total_points << stats[:total_points]
              total_contours << stats[:total_contours]
              max_depth << stats[:max_depth]
            else
              stats = stats_for_simple(maxp, [glyph])
              total_points << stats[:max_points]
              total_contours << stats[:max_contours]
            end
          end

          {
            total_points: total_points,
            total_contours: total_contours,
            max_depth: max_depth
          }
        end
      end

      private

      def parse!
        @version, @num_glyphs = read(6, 'Nn')

        if @version == 0x10000
          @max_points, @max_contours, @max_component_points,
            @max_component_contours, @max_zones, @max_twilight_points,
            @max_storage, @max_function_defs, @max_instruction_defs,
            @max_stack_elements, @max_size_of_instructions,
            @max_component_elements, @max_component_depth = read(28, 'Nn*')

          # a number of fonts omit these last two bytes for some reason,
          # so we have to supply a default here to prevent nils
          @max_component_depth ||= DEFAULT_MAX_COMPONENT_DEPTH
        end
      end
    end
  end
end
