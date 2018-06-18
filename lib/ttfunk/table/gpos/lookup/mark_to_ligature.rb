module TTFunk
  class Table
    class Gpos
      module Lookup
        class MarkToLigature < TTFunk::SubTable
          attr_reader :format, :mark_coverage_offset, :ligature_coverage_offset
          attr_reader :mark_class_count, :mark_array_offset, :ligature_array_offset
          attr_reader :mark_array, :ligature_array

          def self.create(file, _parent_table, offset, lookup_type)
            new(file, offset, lookup_type)
          end

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
