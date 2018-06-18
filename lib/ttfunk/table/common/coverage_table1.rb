module TTFunk
  class Table
    module Common
      class CoverageTable1 < TTFunk::SubTable
        attr_reader :format, :glyph_ids

        def encode
          EncodedString.create do |result|
            result.write([format, glyph_ids.count], 'nn')
            glyph_ids.encode_to(result)
          end
        end

        private

        def parse!
          @format, count = read(4, 'nn')
          @glyph_ids = Sequence.from(io, count, 'n')
          @length = 4 + glyph_ids.length
        end
      end
    end
  end
end
