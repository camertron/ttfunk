module TTFunk
  class Table
    class Gpos
      class PosRule < TTFunk::SubTable
        attr_reader :input_sequence, :pos_lookup_tables

        private

        def parse!
          glyph_count, pos_count = read(4, 'nn')

          @input_sequence = Sequence.from(io, glyph_count - 1, 'n')
          @pos_lookup_tables = Array.new(pos_count) do
            PosLookupTable.new(file, io.pos)
          end

          @length = 4 + input_sequence.length + pos_lookup_tables.length
        end
      end
    end
  end
end
