module TTFunk
  class Table
    module Common
      class CoverageTable2 < TTFunk::SubTable
        attr_reader :format, :range_tables

        private

        def parse!
          @format, count = read(4, 'nn')

          @range_tables = Sequence.from(io, count, 'n') do |range_table_offset|
            RangeTable.new(table_offset + range_table_offset)
          end

          @length = 4 + range_tables.length
        end
      end
    end
  end
end
