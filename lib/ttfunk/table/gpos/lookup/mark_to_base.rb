module TTFunk
  class Table
    class Gpos
      module Lookup
        class MarkToBase < Base
          attr_reader :format, :mark_coverage_offset, :base_coverage_offset
          attr_reader :mark_class_count, :mark_array_offset, :base_array_offset
          attr_reader :mark_array, :base_array

          def mark_coverage_table
            @mark_coverage_table ||= Common::CoverageTable.create(
              file, self, table_offset + mark_coverage_offset
            )
          end

          def base_coverage_table
            @base_coverage_table ||= Common::CoverageTable.create(
              file, self, table_offset + base_coverage_offset
            )
          end

          def dependent_coverage_tables
            [mark_coverage_table, base_coverage_table]
          end

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << mark_coverage_table.placeholder
              result << base_coverage_table.placeholder
              result << [mark_class_count].pack('n')
              result << mark_array.placeholder
              result << base_array.placeholder

              result.resolve_placeholder(mark_array.id, [result.length].pack('n'))
              result << mark_array.encode

              result.resolve_placeholder(base_array.id, [result.length].pack('n'))
              result << base_array.encode
            end
          end

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
