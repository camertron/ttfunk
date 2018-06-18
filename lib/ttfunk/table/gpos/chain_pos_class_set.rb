module TTFunk
  class Table
    class Gpos
      class ChainPosClassSet < TTFunk::SubTable
        attr_reader :chain_pos_class_rules

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
