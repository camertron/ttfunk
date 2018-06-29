module TTFunk
  class Table
    class Gpos
      class PosClassSet < TTFunk::SubTable
        attr_reader :pos_class_rules

        def encode
          EncodedString.new do |result|
            result << [pos_class_rules.count].pack('n')
            pos_class_rules.encode_to(result) do |pos_class_rule|
              [pos_class_rule.placeholder]
            end

            pos_class_rules.each do |pos_class_rule|
              result.resolve_placeholder(pos_class_rule.id, [result.length].pack('n'))
              result << pos_class_rule.encode
            end
          end
        end

        private

        def parse!
          count = read(2, 'n').first

          @pos_class_rules = Sequence.from(io, count, 'n') do |pos_class_rule_offset|
            PosClassRule.new(file, table_offset + pos_class_rule_offset)
          end

          @length = 2 + pos_class_rules.length
        end
      end
    end
  end
end
