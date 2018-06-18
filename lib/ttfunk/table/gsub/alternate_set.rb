module TTFunk
  class Table
    class Gsub
      class AlternateSet < TTFunk::SubTable
        attr_reader :glyph_ids

        def encode
          EncodedString.create do |result|
            result.write(glyph_ids.count, 'n')
            glyph_ids.encode_to(result)
          end
        end

        private

        def parse!
          count = read(2, 'n').first
          @glyph_ids = Sequence.from(io, count, 'n')
          @length = 2 + glyph_ids.length
        end
      end
    end
  end
end
