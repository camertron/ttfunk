module TTFunk
  class Table
    module Common
      class SequenceTable < TTFunk::SubTable
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
