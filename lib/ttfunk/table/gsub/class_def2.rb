module TTFunk
  class Table
    class Gsub
      class ClassDef2 < TTFunk::SubTable
        attr_reader :format, :class_range_tables

        def encode
          EncodedString.create do |result|
            result.write([format, class_range_tables.count], 'nn')

            class_range_tables.each do |class_range_table|
              result << class_range_table.encode
            end
          end
        end

        private

        def parse!
          @format, count = read(4, 'nn')
          @class_range_tables = ClassRangeTable.create_sequence(io, count)
          @length = 4 + sum(class_range_tables, &:length)
        end
      end
    end
  end
end
