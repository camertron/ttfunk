module TTFunk
  class Table
    module Common
      module Subst
        class Chaining1 < TTFunk::SubTable
          attr_reader :format, :coverage_offset, :chain_sub_rule_sets

          def coverage_table
            @coverage_table ||= CoverageTable.create(self, coverage_offset)
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
end
