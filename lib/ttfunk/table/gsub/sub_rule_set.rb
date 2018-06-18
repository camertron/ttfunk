module TTFunk
  class Table
    class Gsub
      class SubRuleSet < TTFunk::SubTable
        attr_reader :sub_rules

        def encode
          EncodedString.new do |result|
            result << [sub_rules.count].pack('n')
            sub_rules.encode_to(result) do |sub_rule|
              [Placeholder.new("gsub_#{sub_rule.id}", length: 2)]
            end

            sub_rules.each do |sub_rule|
              result.resolve_placeholder(
                "gsub_#{sub_rule.id}", [result.length].pack('n')
              )

              result << sub_rule.encode
            end
          end
        end

        def length
          @length + sum(sub_rules, &:length)
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
