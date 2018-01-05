module TTFunk
  class Table
    module Common
      class AlternateSet < TTFunk::SubTable
        GLYPH_ID_LENGTH = 2

        attr_reader :glyph_ids

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
