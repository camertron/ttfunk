module TTFunk
  class Table
    module Common
      class ChainSubRuleSet < TTFunk::SubTable
        attr_reader :chain_sub_rules

        private

        def parse!
          count = read(2, 'n').first

          @chain_sub_rules = Sequence.from(io, count, 'n') do |chain_rule_offset|
            ChainSubRuleTable.new(file, table_offset + chain_rule_offset)
          end

          @length = 2 + chain_sub_rules.length
        end
      end
    end
  end
end
