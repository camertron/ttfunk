module TTFunk
  class Table
    class Gpos
      class PosClassRule < TTFunk::SubTable
        attr_reader :classes, :pos_lookups

        private

        def parse!
          glyph_count, pos_count = read(4, 'nn')

          @classes = Sequence.from(io, glyph_count - 1, 'n')
          @pos_lookups = Array.new(pos_count) do
            PosLookupTable.new(file, io.pos)
          end

          @length = 4 +
            sum(classes, &:length) +
            sum(pos_lookups, &:length)
        end
      end
    end
  end
end
