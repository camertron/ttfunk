module TTFunk
  class Table
    class Gsub
      # This is identical to SubRule, maybe consider combining them if
      # it's not too confusing? Documentation says they're different.
      class SubClassRule < TTFunk::SubTable
        attr_reader :input_sequence, :subst_lookup_tables

        def encode
          EncodedString.new do |result|
            result << [input_sequence.count + 1, subst_lookup_tables.count].pack('nn')
            input_sequence.encode_to(result)
            subst_lookup_tables.encode_to(result) do |subst_lookup_table|
              [
                subst_lookup_table.glyph_sequence_index,
                subst_lookup_table.lookup_list_index
              ]
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
