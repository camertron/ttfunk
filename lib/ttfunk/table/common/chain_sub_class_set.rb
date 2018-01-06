module TTFunk
  class Table
    module Common
      class ChainSubClassSet < TTFunk::SubTable
        attr_reader :chain_sub_class_rules

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
