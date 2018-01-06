module TTFunk
  class Table
    module Common
      # This is identical to SubRule, maybe consider combining them if
      # it's not too confusing? Documentation says they're different.
      class SubClassRule < TTFunk::SubTable
        attr_reader :input_sequence, :subst_lookup_tables

        private

        def parse!
          glyph_count, subst_count = read(4, 'nn')
          @input_sequence = Sequence.from(io, glyph_count - 1, 'n')
          @subst_lookup_tables = Sequence.from(io, subst_count, SubstLookupTable::FORMAT) do |*args|
            SubstLookupTable.new(*args)
          end

          @length = 4 + input_sequence.length + subst_lookup_tables.length
        end
      end
    end
  end
end
