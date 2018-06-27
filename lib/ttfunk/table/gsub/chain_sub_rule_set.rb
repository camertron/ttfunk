module TTFunk
  class Table
    class Gsub
      class ChainSubRuleSet < TTFunk::SubTable
        attr_reader :chain_sub_rules

        def encode
          EncodedString.new do |result|
            result << [chain_sub_rules.count].pack('n')
            chain_sub_rules.encode_to(result) do |chain_sub_rule|
              chain_sub_rule.placeholder
            end

            chain_sub_rules.each do |chain_sub_rule|
              result.resolve_placeholder(
                chain_sub_rule.id, [result.length].pack('n')
              )

              result << chain_sub_rule.encode
            end
          end
        end

        def length
          @length + sum(chain_sub_rules, &:length)
        end

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
