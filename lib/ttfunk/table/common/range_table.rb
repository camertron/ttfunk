module TTFunk
  class Table
    module Common
      class RangeTable < TTFunk::SubTable
        attr_reader :start_glyph_id, :end_glyph_id, :start_coverage_index

        def encode
          EncodedString.create do |result|
            result.write([start_glyph_id, end_glyph_id, start_coverage_index], 'nnn')
          end
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
