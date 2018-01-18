module TTFunk
  class Table
    class Gpos
      module Lookup
        class MarkToBase < TTFunk::SubTable
          attr_reader :format, :mark_coverage_offset, :base_coverage_offset
          attr_reader :mark_class_count, :mark_array_offset, :base_array_offset
          attr_reader :mark_array, :base_array

          private

          def parse!
            @format, @mark_coverage_offset, @base_coverage_offset,
              @mark_class_count, @mark_array_offset, @base_array_offset = read(12, 'n6')

            @mark_array = MarkArray.new(file, table_offset + mark_array_offset)
            @base_array = BaseArray.new(file, table_offset + base_array_offset, mark_class_count)

            @length = 12 + mark_array.length + base_array.length
          end
        end
      end
    end
  end
end
