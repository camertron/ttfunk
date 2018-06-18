module TTFunk
  class Table
    class Gpos
      class PairValueTable < TTFunk::SubTable
        attr_reader :second_glyph, :value_table1, :value_table2
        attr_reader :value_format1, :value_format2, :lookup_table_offset

        def initialize(file, offset, value_format1, value_format2, lookup_table_offset)
          @value_format1 = value_format1
          @value_format2 = value_format2
          @lookup_table_offset = lookup_table_offset
          super(file, offset)
        end

        private

        def parse!
          @second_glyph = read(2, 'n').first

          value_table1_len = 0

          if value_format1 != 0
            @value_table1 = ValueTable.new(
              file,
              table_offset + 2,
              value_format1,
              lookup_table_offset
            )

            value_table1_len = value_table1.length
          end

          value_table2_len = 0

          if value_format2 != 0
            @value_table2 = ValueTable.new(
              file,
              table_offset + value_table1_len + 2,
              value_format2,
              lookup_table_offset
            )

            value_table2_len = value_table2.length
          end

          @length = 2 + value_table1_len + value_table2_len
        end
      end
    end
  end
end
