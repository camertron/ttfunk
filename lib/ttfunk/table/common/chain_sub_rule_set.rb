module TTFunk
  class Table
    module Common
      class ChainSubRuleSet < TTFunk::SubTable
        attr_reader :chain_sub_rules

        def encode
          EncodedString.create do |result|
            result.write(chain_sub_rules.count, 'n')
            result << chain_sub_rules.encode do |chain_sub_rule|
              [ph(:common, chain_sub_rule.id, 2)]
            end

            chain_sub_rule.each do |chain_sub_rule|
              result.resolve_placeholder(
                :common, chain_sub_rule.id, [result.length].encode('n')
              )

              result << chain_sub_rule.encode
            end
          end
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
