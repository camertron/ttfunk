module TTFunk
  class Table
    module Common
      class ClassDef2 < TTFunk::SubTable
        attr_reader :format, :class_range_tables

        private

        def parse!
          @format, count = read(4, 'n')

          @class_range_tables = Sequence.new(io, count, 'n') do |class_range_offset|
            ClassRangeTable.new(table_offset + class_range_offset)
          end

          @length = 4 + class_range_tables.length
        end
      end
    end
  end
end
