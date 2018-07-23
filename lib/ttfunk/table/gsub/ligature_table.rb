module TTFunk
  class Table
    class Gsub
      class LigatureTable < TTFunk::SubTable
        attr_reader :ligature_glyph_id, :component_glyph_ids

        def encode
          EncodedString.new do |result|
            result << [ligature_glyph_id, component_glyph_ids.count + 1].pack('nn')
            component_glyph_ids.encode_to(result)
          end
        end

        private

        def parse!
          @ligature_glyph_id, count = read(4, 'nn')
          @component_glyph_ids = Sequence.from(io, count - 1, 'n')
          @length = 4 + component_glyph_ids.length
        end
      end
    end
  end
end
