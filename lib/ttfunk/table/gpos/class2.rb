module TTFunk
  class Table
    class Gpos
      class Class2 < TTFunk::SubTable
        attr_reader :value_record1, :value_record2
        attr_reader :value_format1, :value_format2
        attr_reader :lookup_table_offset

        def initialize(file, offset, value_format1, value_format2, lookup_table_offset)
          @value_format1 = value_format1
          @value_format2 = value_format2
          @lookup_table_offset = lookup_table_offset
          super(file, offset)
        end

        private

        def parse!
          value_record1_len = 0

          if value_format1 != 0
            @value_record1 = ValueTable.new(
              file,
              table_offset,
              value_format1,
              lookup_table_offset
            )

            value_record1_len = value_record1.length
          end

          value_record2_len = 0

          if value_format2 != 0
            @value_record2 = ValueTable.new(
              file,
              table_offset + value_record1_len,
              value_format2,
              lookup_table_offset
            )

            value_record2_len = value_record2.length
          end

          @length = value_record1_len + value_record2_len
        end
      end
    end
  end
end
