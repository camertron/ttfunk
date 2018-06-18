module TTFunk
  class Table
    class Gsub
      class ChainSubRuleSet < TTFunk::SubTable
        attr_reader :chain_sub_rules

        def encode
          EncodedString.create do |result|
            result.write(chain_sub_rules.count, 'n')
            chain_sub_rules.encode_to(result) do |chain_sub_rule|
              [ph(:gsub, chain_sub_rule.id, length: 2)]
            end

            chain_sub_rules.each do |chain_sub_rule|
              result.resolve_placeholders(
                :gsub, chain_sub_rule.id, [result.length].pack('n')
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
