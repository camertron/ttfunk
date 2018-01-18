module TTFunk
  class Table
    class Gpos
      class Class2 < TTFunk::SubTable
        attr_reader :value_record1, :value_record2

        private

        def parse!
          @value_record1 = ValueRecord.new(file, table_offset)
          @value_record2 = ValueRecord.new(file, table_offset + value_record1.length)
          @length = value_record1.length + value_record2.length
        end
      end
    end
  end
end
