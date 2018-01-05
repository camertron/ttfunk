module TTFunk
  class Table
    module Common
      class SubRuleSet < TTFunk::SubTable
        attr_reader :sub_rules

        private

        def parse!
          count = read(2, 'n').first

          @sub_rules = Sequence.from(io, count, 'n') do |sub_rule_offset|
            SubRule.new(file, table_offset + sub_rule_offset)
          end

          @length = 2 + sub_rules.length
        end
      end
    end
  end
end
