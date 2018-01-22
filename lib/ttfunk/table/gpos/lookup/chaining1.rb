module TTFunk
  class Table
    class Gpos
      module Lookup
        class Chaining1 < TTFunk::SubTable
          attr_reader :format, :coverage_offset, :chain_pos_rule_sets

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'nnn')

            @chain_pos_rule_sets = Sequence.from(io, count, 'n') do |chain_pos_rule_set_offset|
              ChainPosRuleSet.new(table_offset + chain_pos_rule_set_offset)
            end

            @length = 6 + chain_pos_rule_sets.length
          end
        end
      end
    end
  end
end
