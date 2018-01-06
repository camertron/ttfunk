module TTFunk
  class Table
    module Common
      class ChainRuleTable < TTFunk::SubTable
        attr_reader :backtrack_glyph_ids, :input_glyph_ids, :lookahead_glyph_ids
        attr_reader :subst_lookup_tables

        private

        def parse!
          backtrack_count = read(2, 'n').first
          @backtrack_glyph_ids = Sequence.from(io, backtrack_count, 'n')
          input_count = read(2, 'n').first
          @input_glyph_ids = Sequence.from(io, input_count - 1, 'n')
          lookahead_count = read(2, 'n').first
          @lookahead_glyph_ids = Sequence.from(io, input_count, 'n')
          subst_count = read(2, 'n').first
          @subst_lookup_tables = Sequence.from(io, subst_count, SubstLookupTable::FORMAT) do |*args|
            SubstLookupTable.new(*args)
          end

          @length = 8 + backtrack_glyph_ids.length +
            input_glyph_ids.length + lookahead_glyph_ids.length +
            subst_lookup_tables.length
        end
      end
    end
  end
end
