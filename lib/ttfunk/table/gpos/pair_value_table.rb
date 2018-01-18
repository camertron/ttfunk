module TTFunk
  class Table
    class Gpos
      class PairValueTable < TTFunk::SubTable
        attr_reader :second_glyph, :value_table1, :value_table2

        private

        def parse!
          @second_glyph = read(2, 'n').first
          @value_table1 = ValueTable.new(file, table_offset + 2)
          @value_table2 = ValueTable.new(file, table_offset + value_table1.length + 2)
        end
      end
    end
  end
end
