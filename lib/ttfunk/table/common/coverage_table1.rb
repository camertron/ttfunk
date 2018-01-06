module TTFunk
  class Table
    module Common
      class CoverageTable1 < TTFunk::SubTable
        attr_reader :format, :glyph_ids

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
