module TTFunk
  class Table
    module Common
      class SubClassSet < TTFunk::SubTable
        attr_reader :sub_class_rules

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
