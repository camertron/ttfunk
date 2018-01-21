module TTFunk
  class Table
    class Gpos
      class PosClassSet < TTFunk::SubTable
        attr_reader :pos_class_rules

        private

        def parse!
          count = read(2, 'n').first

          @pos_class_rules = Sequence.new(io, count, 'n') do |pos_class_rule_offset|
            PosClassRule.new(file, table_offset + pos_class_rule_offset)
          end

          @length = 2 + pos_class_rules.length
        end
      end
    end
  end
end
