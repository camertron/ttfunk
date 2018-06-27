module TTFunk
  class Table
    class Gpos
      class ChainPosClassRule < TTFunk::SubTable
        attr_reader :backtrack_sequence, :input_sequence
        attr_reader :lookahead_sequence, :pos_lookups

        private

        def parse!
          backtrack_glyph_count = read(2, 'n').first
          @backtrack_sequence = Sequence.from(io, backtrack_glyph_count, 'n')
          input_glyph_count = read(2, 'n').first
          @input_sequence = Sequence.from(io, input_glyph_count, 'n')
          lookahead_glyph_count = read(2, 'n').first
          @lookahead_sequence = Sequence.from(io, lookahead_glyph_count, 'n')
          pos_count = read(2, 'n').first
          @pos_lookups = Array.new(pos_count) do
            PosLookupTable.new(file, io.pos)
          end

          @length = 8 +
            backtrack_sequence.length +
            input_sequence.length +
            lookahead_sequence.length +
            pos_lookups.length
        end
      end
    end
  end
end
