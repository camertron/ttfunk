module TTFunk
  class Table
    class Gpos
      class ChainPosRuleSet < TTFunk::SubTable
        attr_reader :chain_pos_rules

        private

        def parse!
          count = read(2, 'n').first

          @chain_pos_rules = Sequence.from(io, count, 'n') do |chain_pos_rule_offset|
            ChainPosRule.new(table_offset + chain_pos_rule_offset)
          end

          @length = 2 + chain_pos_rules.length
        end
      end
    end
  end
end
