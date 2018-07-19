module TTFunk
  class Table
    class Gpos
      module Lookup
        class MarkToMark < Base
          attr_reader :format, :mark1_coverage_offset, :mark2_coverage_offset
          attr_reader :mark_class_count, :mark1_array_offset, :mark2_array_offset
          attr_reader :mark1_array, :mark2_array

          def max_context
            2
          end

          def mark1_coverage_table
            @mark1_coverage_table ||= Common::CoverageTable.create(
              file, self, table_offset + mark1_coverage_offset
            )
          end

          def mark2_coverage_table
            @mark2_coverage_table ||= Common::CoverageTable.create(
              file, self, table_offset + mark2_coverage_offset
            )
          end

          def dependent_coverage_tables
            [mark1_coverage_table, mark2_coverage_table]
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format].pack('n')
              result << mark1_coverage_table.placeholder_relative_to(id)
              result << mark2_coverage_table.placeholder_relative_to(id)
              result << [mark1_array.marks.count].pack('n')
              result << mark1_array.placeholder
              result << mark2_array.placeholder

              result.resolve_placeholder(mark1_array.id, [result.length].pack('n'))
              result << mark1_array.encode

              result.resolve_placeholder(mark2_array.id, [result.length].pack('n'))
              result << mark2_array.encode
            end
          end

          private

          def parse!
            @format, @mark1_coverage_offset, @mark2_coverage_offset,
              @mark_class_count, @mark1_array_offset, @mark2_array_offset = read(12, 'n6')

            @mark1_array = MarkArray.new(file, table_offset + mark1_array_offset)
            @mark2_array = Mark2Array.new(
              file, table_offset + mark2_array_offset, mark_class_count, mark2_array_offset
            )

            @length = 12 + mark1_array.length + mark2_array.length
          end
        end
      end
    end
  end
end
