module TTFunk
  class Table
    module Common
      class ChainSubClassSet < TTFunk::SubTable
        attr_reader :chain_sub_class_rules

        def encode
          EncodedString.create do |result|
            result.write(chain_sub_class_rules.count, 'n')
            result << chain_sub_class_rules.encode do |chain_sub_class_rule|
              [ph(:common, chain_sub_class_rule.id, 2)]
            end

            chain_sub_class_rules.each do |chain_sub_class_rule|
              result.resolve_placeholder(
                :common, chain_sub_class_rule.id, [result.length].encode('n')
              )

              result << chain_sub_class_rule.encode
            end
          end
        end

        private

        def parse!
          count = read(2, 'n').first

          @chain_sub_class_rules = Sequence.from(io, count, 'n') do |chain_sub_class_rule_offset|
            ChainSubClassRuleTable.new(file, table_offset + chain_sub_class_rule_offset)
          end

          @length = 2 + chain_sub_class_rules.length
        end
      end
    end
  end
end
