module TTFunk
  class Table
    module Common
      class ConditionSet < TTFunk::SubTable
        attr_reader :conditions

        private

        def parse!
          condition_count = read(2, 'n').first

          @conditions = Sequence.from(io, count, 'N') do |condition_table_offset|
            ConditionTable.new(self, table_offset + condition_table_offset)
          end

          @length = 2 + conditions.length
        end
      end
    end
  end
end
