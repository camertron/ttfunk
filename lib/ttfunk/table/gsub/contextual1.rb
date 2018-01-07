module TTFunk
  class Table
    class Gsub
      class Contextual1 < TTFunk::SubTable
        attr_reader :format, :coverage_offset, :sub_rule_sets

        def coverage_table
          @coverage_table ||= CoverageTable.create(
            file, self, table_offset + coverage_offset
          )
        end

        def max_context
          @max_context ||= sub_rule_sets.flat_map do |sub_rule_set|
            sub_rule_set.sub_rules.map do |sub_rule|
              sub_rule.input_sequence.count
            end
          end.max
        end

        private

        def parse!
          @format, @coverage_offset, count = read(6, 'nnn')

          @sub_rule_sets = Sequence.from(io, count, 'n') do |sub_rule_set_offset|
            SubRuleSet.new(file, table_offset + sub_rule_set_offset)
          end

          @length = 6 + sub_rule_sets.length
        end
      end
    end
  end
end
