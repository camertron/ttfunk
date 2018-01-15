module TTFunk
  class Table
    module Common
      class SubClassSet < TTFunk::SubTable
        attr_reader :sub_class_rules

        def encode
          EncodedString.create do |result|
            result.write(sub_class_rules.count, 'n')
            sub_class_rules.encode_to(result) do |sub_class_rule|
              [ph(:common, sub_class_rule.id, length: 2)]
            end

            sub_class_rules.each do |sub_class_rule|
              result.resolve_placeholders(
                :common, sub_class_rule.id, [result.length].pack('n')
              )

              result << sub_class_rule.encode
            end
          end
        end

        private

        def parse!
          count = read(2, 'n')

          @sub_class_rules = Sequence.from(io, count, 'n') do |sub_class_rule_offset|
            SubClassRule.new(table_offset + sub_class_rule_offset)
          end

          @length = 2 + sub_class_rules.length
        end
      end
    end
  end
end
