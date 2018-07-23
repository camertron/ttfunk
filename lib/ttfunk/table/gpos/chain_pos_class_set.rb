module TTFunk
  class Table
    class Gpos
      class ChainPosClassSet < TTFunk::SubTable
        attr_reader :chain_pos_class_rules

        def encode
          EncodedString.new do |result|
            result << [chain_pos_class_rules.count].pack('n')
            chain_pos_class_rules.encode_to(result) do |chain_pos_class_rule|
              [chain_pos_class_rule.placeholder]
            end

            chain_pos_class_rules.each do |chain_pos_class_rule|
              result.resolve_placeholder(chain_pos_class_rule.id, [result.length].pack('n'))
              result << chain_pos_class_rule.encode
            end
          end
        end

        private

        def parse!
          count = read(2, 'n')

          @chain_pos_class_rules = Sequence.from(io, count, 'n') do |chain_pos_class_rule_offset|
            ChainPosClassRule.new(file, table_offset + chain_pos_class_rule_offset)
          end

          @length = 2 + chain_pos_class_rules.length
        end
      end
    end
  end
end
