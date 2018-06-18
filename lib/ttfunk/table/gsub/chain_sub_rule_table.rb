module TTFunk
  class Table
    class Gsub
      class ChainSubRuleTable < TTFunk::SubTable
        attr_reader :backtrack_glyph_ids, :input_glyph_ids, :lookahead_glyph_ids
        attr_reader :subst_lookup_tables

        def encode
          EncodedString.create do |result|
            result.write(backtrack_glyph_ids.count, 'n')
            backtrack_glyph_ids.encode_to(result)
            result.write(input_glyph_ids.count + 1, 'n')
            input_glyph_ids.encode_to(result)
            result.write(lookahead_glyph_ids.count, 'n')
            lookahead_glyph_ids.encode_to(result)
            result.write(subst_lookup_tables.count, 'n')
            subst_lookup_tables.encode_to(result) do |subst_lookup_table|
              [subst_lookup_table.glyph_sequence_index, subst_lookup_table.lookup_list_index]
            end
          end
        end

        private

        def parse!
          backtrack_count = read(2, 'n').first
          @backtrack_glyph_ids = Sequence.from(io, backtrack_count, 'n')
          input_count = read(2, 'n').first
          @input_glyph_ids = Sequence.from(io, input_count - 1, 'n')
          lookahead_count = read(2, 'n').first
          @lookahead_glyph_ids = Sequence.from(io, lookahead_count, 'n')
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
