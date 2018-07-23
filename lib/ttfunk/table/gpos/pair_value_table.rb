module TTFunk
  class Table
    class Gpos
      class PairValueTable < TTFunk::SubTable
        attr_reader :second_glyph, :value_table1, :value_table2
        attr_reader :value_format1, :value_format2, :lookup_table

        def initialize(file, offset, value_format1, value_format2, lookup_table)
          @value_format1 = value_format1
          @value_format2 = value_format2
          @lookup_table = lookup_table
          super(file, offset)
        end

        def encode
          EncodedString.new do |result|
            result << [second_glyph].pack('n')
            result << value_table1.encode if value_table1
            result << value_table2.encode if value_table2
          end
        end

        def finalize(data)
          value_table1.finalize(data) if value_format1 != 0
          value_table2.finalize(data) if value_format2 != 0
        end

        private

        def parse!
          @second_glyph = read(2, 'n').first

          value_table1_len = 0

          if value_format1 != 0
            @value_table1 = ValueTable.new(
              file,
              table_offset,
              value_format1,
              lookup_table
            )

            value_table1_len = value_table1.length
          end

          value_table2_len = 0

          if value_format2 != 0
            @value_table2 = ValueTable.new(
              file,
              table_offset + value_table1_len,
              value_format2,
              lookup_table
            )

            value_table2_len = value_table2.length
          end

          @length = 2 + value_table1_len + value_table2_len
        end
      end
    end
  end
end
