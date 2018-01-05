module TTFunk
  class Table
    module Common
      # This is identical to SubClassRule, maybe consider combining them
      # if it's not too confusing? Documentation says they're different.
      class SubRule < TTFunk::SubTable
        attr_reader :input_sequence, :subst_lookup_tables

        private

        def parse!
          glyph_count, subst_count = read(4, 'nn')
          @input_sequence = Sequence.from(io, glyph_count - 1, 'n')
          @subst_lookup_tables = Sequence.from(io, subst_count, SubstLookupTable::FORMAT) do |*args|
            SubstLookupTable.new(*args)
          end
        end
      end
    end
  end
end
