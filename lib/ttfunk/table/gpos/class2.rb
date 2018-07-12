module TTFunk
  class Table
    class Gpos
      class Class2 < TTFunk::SubTable
        attr_reader :value_record1, :value_record2
        attr_reader :value_format1, :value_format2
        attr_reader :lookup_table

        def initialize(file, offset, value_format1, value_format2, lookup_table)
          @value_format1 = value_format1
          @value_format2 = value_format2
          @lookup_table = lookup_table
          super(file, offset)
        end

        def encode
          EncodedString.new do |result|
            result << value_record1.encode if value_record1
            result << value_record2.encode if value_record2
          end
        end

        def finalize(data)
          value_record1.finalize(data)
          value_record2.finalize(data)
        end

        private

        def parse!
          value_record1_len = 0

          if value_format1 != 0
            @value_record1 = ValueTable.new(
              file,
              table_offset,
              value_format1,
              lookup_table
            )

            value_record1_len = value_record1.length
          end

          value_record2_len = 0

          if value_format2 != 0
            @value_record2 = ValueTable.new(
              file,
              table_offset + value_record1_len,
              value_format2,
              lookup_table
            )

            value_record2_len = value_record2.length
          end

          @length = value_record1_len + value_record2_len
        end
      end
    end
  end
end
