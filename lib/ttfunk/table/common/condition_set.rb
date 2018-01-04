module TTFunk
  class Table
    module Common
      class ConditionSet < TTFunk::SubTable
        attr_reader :conditions

        private

        def parse!
          condition_count = read(2, 'n').first
          condition_table_offset_array = io.read(condition_count * 4)

          @conditions = Sequence.new(condition_table_offset_array, 4) do |condition_table_data|
            condition_table_offset = condition_table_offset.unpack('N').first
            ConditionTable.new(self, table_offset + condition_table_offset)
          end

          @length = 2 + conditions.length
        end
      end
    end
  end
end
