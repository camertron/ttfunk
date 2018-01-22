module TTFunk
  class Table
    class Gpos
      module Lookup
        class MarkToMark < TTFunk::SubTable
          attr_reader :mark1_coverage_offset, :mark2_coverage_offset
          attr_reader :mark_class_count, :mark1_array_offset
          attr_reader :mark2_array_offset

          private

          def parse!
            @format, @mark1_coverage_offset, @mark2_coverage_offset,
              @mark_class_count, @mark1_array_offset, @mark2_array_offset = read(12, 'n6')

            @mark1_array = MarkArray.new(file, table_offset + mark1_array_offset)
            @mark2_array = Mark2Array.new(
              file, table_offset + mark2_array_offset, mark_class_count
            )

            @length = 12 + mark1_array.length + mark2_array.length
          end
        end
      end
    end
  end
end
