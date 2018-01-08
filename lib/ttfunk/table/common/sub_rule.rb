module TTFunk
  class Table
    module Common
      # This is identical to SubClassRule, maybe consider combining them
      # if it's not too confusing? Documentation says they're different.
      class SubRule < TTFunk::SubTable
        attr_reader :input_sequence, :subst_lookup_tables

        def encode
          EncodedString.create do |result|
            result.write([input_sequence.count, subst_lookup_tables.count], 'nn')
            result << input_sequence.encode
            result.write(subst_lookup_tables.count, 'n')
            result << subst_lookup_tables.encode do |subst_lookup_table|
              [subst_lookup_table.glyph_sequence_index, subst_lookup_table.lookup_list_index]
            end
          end
        end

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
