# frozen_string_literal: true

module TTFunk
  class Table
    class Gsub
      class ChainSubClassSet < TTFunk::SubTable
        attr_reader :csc_rules

        def encode
          EncodedString.new do |result|
            result << [csc_rules.count].pack('n')
            csc_rules.encode_to(result) do |chain_sub_class_rule|
              [chain_sub_class_rule.placeholder]
            end

            csc_rules.each do |chain_sub_class_rule|
              result.resolve_placeholder(
                chain_sub_class_rule.id, [result.length].pack('n')
              )

              result << chain_sub_class_rule.encode
            end
          end
        end

        def length
          @length + sum(csc_rules, &:length)
        end

        private

        def parse!
          count = read(2, 'n').first

          @csc_rules = Sequence.from(io, count, 'n') do |csc_rule_offset|
            ChainSubClassRuleTable.new(
              file, table_offset + csc_rule_offset
            )
          end

          @length = 2 + csc_rules.length
        end
      end
    end
  end
end
