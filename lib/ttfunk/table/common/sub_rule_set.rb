module TTFunk
  class Table
    module Common
      class SubRuleSet < TTFunk::SubTable
        attr_reader :sub_rules

        def encode
          EncodedString.create do |result|
            result.write(sub_rules.count, 'n')
            result << sub_rules.encode do |sub_rule|
              [ph(:common, sub_rule.id, length: 2)]
            end

            sub_rules.each do |sub_rule|
              result.resolve_placeholders(
                :common, sub_rule.id, [result.length].pack('n')
              )

              result << sub_rule.encode
            end
          end
        end

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
