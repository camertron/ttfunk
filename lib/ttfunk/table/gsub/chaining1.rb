module TTFunk
  class Table
    class Gsub
      class Chaining1 < TTFunk::SubTable
        attr_reader :format, :coverage_offset, :chain_sub_rule_sets

        def coverage_table
          @coverage_table ||= CoverageTable.create(
            file, self, table_offset + coverage_offset
          )
        end

        def max_context
          @max_context ||= chain_sub_rule_sets.flat_map do |chain_sub_rule_set|
            chain_sub_rule_set.chain_sub_rules.map do |chain_sub_rule|
              chain_sub_rule.input_glyph_ids.count + chain_sub_rule.lookahead_glyph_ids.count
            end
          end.max
        end

        private

        def parse!
          @format, @coverage_offset, count = read(6, 'nnn')

          @chain_sub_rule_sets = Sequence.from(io, count, 'n') do |chain_sub_rule_set_offset|
            ChainSubRuleSet.new(file, table_offset + chain_sub_rule_set_offset)
          end

          @length = 6 + chain_sub_rule_sets.length
        end
      end
    end
  end
end
