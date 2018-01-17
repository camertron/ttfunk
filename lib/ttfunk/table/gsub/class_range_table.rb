module TTFunk
  class Table
    class Gsub
      class ClassRangeTable < TTFunk::SubTable
        attr_reader :start_glyph_id, :end_glyph_id, :class_id

        def encode
          EncodedString.create do |result|
            result.write([start_glyph_id, end_glyph_id, class_id], 'nnn')
          end
        end

        private

        def parse!
          @start_glyph_id, @end_glyph_id, @class_id = read(6, 'nnn')
          @length = 6
        end
      end
    end
  end
end
