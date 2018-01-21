module TTFunk
  class Table
    class Gpos
      class PosRuleSet < TTFunk::SubTable
        attr_reader :pos_rules

        private

        def parse!
          count = read(2, 'n').first

          @pos_rules = Sequence.from(io, count, 'n') do |pos_rule_offset|
            PosRule.new(file, table_offset + pos_rule_offset)
          end

          @length = 2 + pos_rules.length
        end
      end
    end
  end
end
