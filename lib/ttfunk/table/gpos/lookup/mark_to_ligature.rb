module TTFunk
  class Table
    class Gpos
      module Lookup
        class MarkToLigature < Base
          attr_reader :format, :mark_coverage_offset, :ligature_coverage_offset
          attr_reader :mark_class_count, :mark_array_offset, :ligature_array_offset
          attr_reader :mark_array, :ligature_array

          def mark_coverage_table
            @mark_coverage_table ||= Common::CoverageTable.create(
              file, self, table_offset + mark_coverage_offset
            )
          end

          def ligature_coverage_table
            @base_coverage_table ||= Common::CoverageTable.create(
              file, self, table_offset + ligature_coverage_offset
            )
          end

          def dependent_coverage_tables
            [mark_coverage_table, ligature_coverage_table]
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format].pack('n')
              result << mark_coverage_table.placeholder_relative_to(id)
              result << ligature_coverage_table.placeholder_relative_to(id)
              result << [mark_array.count].pack('n')
              result << mark_array.placeholder
              result << ligature_array.placeholder

              result.resolve_placeholder(mark_array.id, [result.length].pack('n'))
              result << mark_array.encode

              result.resolve_placeholder(ligature_array.id, [result.length].pack('n'))
              result << ligature_array.encode
            end
          end

          private

          def parse!
            @format, @mark_coverage_offset, @ligature_coverage_offset,
              @mark_class_count, @mark_array_offset, @ligature_array_offset = read(12, 'n6')

            @mark_array = MarkArray.new(file, table_offset + mark_array_offset)
            @ligature_array = LigatureArray.new(
              file, table_offset + ligature_array_offset, mark_class_count
            )

            @length = 12
          end
        end
      end
    end
  end
end
