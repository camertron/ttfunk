module TTFunk
  class Table
    class Gpos
      class ChainPosRule < TTFunk::SubTable
        attr_reader :backtrack_glyph_ids, :input_sequence
        attr_reader :lookahead_glyph_ids, :pos_lookups

        private

        def parse!
          backtrack_glyph_count = read(2, 'n').first
          @backtrack_glyph_ids = Sequence.from(io, backtrack_glyph_count, 'n')
          input_glyph_count = read(2, 'n').first
          @input_sequence = Sequence.from(io, input_glyph_count, 'n')
          lookahead_glyph_count = read(2, 'n').first
          @lookahead_glyph_ids = Sequence.from(io, lookahead_glyph_count, 'n')
          pos_count = read(2, 'n').first
          @pos_lookups = Array.new(pos_count) do
            PosLookupTable.new(file, io.pos)
          end

          @length = 8 +
            backtrack_glyph_ids.length +
            input_sequence.length +
            lookahead_glyph_ids.length +
            pos_lookups.length
        end
      end
    end
  end
end
