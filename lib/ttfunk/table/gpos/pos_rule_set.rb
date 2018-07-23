module TTFunk
  class Table
    class Gpos
      class PosRuleSet < TTFunk::SubTable
        attr_reader :pos_rules

        def encode
          EncodedString.new do |result|
            result << [pos_rules.count].pack('n')
            pos_rules.encode_to(result) do |pos_rule|
              [pos_rule.placeholder]
            end

            pos_rules.each do |pos_rule|
              result.resolve_placeholder(pos_rule.id, [result.length].pack('n'))
              result << pos_rule.encode
            end
          end
        end

        private

        def parse!
          count = read(2, 'n').first

          @pos_rules = Sequence.from(io, count, 'n') do |pos_rule_offset|
            PosRule.new(file, table_offset + pos_rule_offset)
          end

          @length = 2 + pos_rules.length
        end
      end
    end
  end
end
