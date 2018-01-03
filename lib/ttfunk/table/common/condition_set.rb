module TTFunk
  class Table
    module Common
      class ConditionSet < TTFunk::SubTable
        include Enumerable

        CONDITION_RECORD_LENGTH = 4

        attr_reader :count

        def each
          return to_enum(__method__) unless block_given?
          count.times { |i| yield self[i] }
        end

        def [](index)
          condition_tables[index] ||= begin
            offset = index * CONDITION_RECORD_LENGTH
            condition_offset = @raw_record_array[offset, CONDITION_RECORD_LENGTH].unpack('n').first
            ConditionTable.new(file, table_offset + condition_offset)
          end
        end

        private

        def parse!
          @count = read(2, 'n').first
          @raw_offset_array = read(count * CONDITION_RECORD_LENGTH)
          @length = 2 + @raw_offset_array.length
        end

        def condition_tables
          @condition_tables ||= {}
        end
      end
    end
  end
end
