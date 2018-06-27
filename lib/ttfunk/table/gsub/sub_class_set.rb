module TTFunk
  class Table
    class Gsub
      class SubClassSet < TTFunk::SubTable
        attr_reader :sub_class_rules

        def encode
          EncodedString.new do |result|
            result << [sub_class_rules.count].pack('n')
            sub_class_rules.encode_to(result) do |sub_class_rule|
              [sub_class_rule.placeholder]
            end

            sub_class_rules.each do |sub_class_rule|
              result.resolve_placeholder(
                sub_class_rule.id, [result.length].pack('n')
              )

              result << sub_class_rule.encode
            end
          end
        end

        def length
          @length + sum(sub_class_rules, &:length)
        end

        private

        def parse!
          count = read(2, 'n').first

          @sub_class_rules = Sequence.from(io, count, 'n') do |sub_class_rule_offset|
            SubClassRule.new(file, table_offset + sub_class_rule_offset)
          end

          @length = 2 + sub_class_rules.length
        end
      end
    end
  end
end
