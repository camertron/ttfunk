module TTFunk
  class Table
    class Gsub
      class ChainSubClassSet < TTFunk::SubTable
        attr_reader :chain_sub_class_rules

        def encode
          EncodedString.new do |result|
            result << [chain_sub_class_rules.count].pack('n')
            chain_sub_class_rules.encode_to(result) do |chain_sub_class_rule|
              [Placeholder.new("gsub_#{chain_sub_class_rule.id}", length: 2)]
            end

            chain_sub_class_rules.each do |chain_sub_class_rule|
              result.resolve_placeholder(
                "gsub_#{chain_sub_class_rule.id}", [result.length].pack('n')
              )

              result << chain_sub_class_rule.encode
            end
          end
        end

        def length
          @length + sum(chain_sub_class_rules, &:length)
        end

        private

        def parse!
          count = read(2, 'n').first

          @chain_sub_class_rules = Sequence.from(io, count, 'n') do |chain_sub_class_rule_offset|
            ChainSubClassRuleTable.new(
              file, table_offset + chain_sub_class_rule_offset
            )
          end

          @length = 2 + chain_sub_class_rules.length
        end
      end
    end
  end
end
