# frozen_string_literal: true

module TTFunk
  class Table
    module Common
      class RangeTable < TTFunk::SubTable
        attr_reader :start_glyph_id, :end_glyph_id, :start_coverage_index

        def encode
          EncodedString.new do |result|
            result << [start_glyph_id, end_glyph_id, start_coverage_index]
                      .pack('nnn')
          end
        end

        def glyph_ids
          @glyph_ids ||= (start_glyph_id..end_glyph_id).to_a
        end

        private

        def parse!
          @start_glyph_id, @end_glyph_id, @start_coverage_index = read(6, 'nnn')
          @length = 6
        end
      end
    end
  end
end
