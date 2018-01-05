module TTFunk
  class Table
    module Common
      module Subst
        class Contextual1 < TTFunk::SubTable
          attr_reader :sub_rule_sets

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
end
