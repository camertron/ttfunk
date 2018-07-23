module TTFunk
  class Table
    class Gpos
      class ChainPosRuleSet < TTFunk::SubTable
        attr_reader :chain_pos_rules

        def encode
          EncodedString.new do |result|
            result << [chain_pos_rules.count].pack('n')
            chain_pos_rules.encode_to(result) do |chain_pos_rule|
              [chain_pos_rule.placeholder]
            end

            chain_pos_rules.each do |chain_pos_rule|
              result.resolve_placeholder(chain_pos_rule.id, [result.length].pack('n'))
              result << chain_pos_rule.encode
            end
          end
        end

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
