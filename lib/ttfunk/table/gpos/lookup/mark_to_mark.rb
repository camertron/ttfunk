module TTFunk
  class Table
    class Gpos
      module Lookup
        class MarkToMark < TTFunk::SubTable
          attr_reader :mark1_coverage_offset, :mark2_coverage_offset, :mark_class_count
          attr_reader :mark1_array_offset, :mark2_array_offset
          attr_reader :mark1_array, :mark2_array

          def self.create(file, _parent_table, offset, lookup_type)
            new(file, offset, lookup_type)
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
              result << [format].pack('n')
              result << Placeholder.new("gpos_#{mark1_coverage_table.id}", length: 2, relative_to: 0)
              result << Placeholder.new("gpos_#{mark2_coverage_table.id}", length: 2, relative_to: 0)
              result << [mark1_array.count].pack('n')
              result << Placeholder.new("gpos_#{mark1_array.id}", length: 2, relative_to: 0)
              result << Placeholder.new("gpos_#{mark2_array.id}", length: 2, relative_to: 0)

              result.resolve_placeholder("gpos_#{mark1_array.id}", [result.length].pack('n'))
              result << mark1_array.encode

              result.resolve_placeholder("gpos_#{mark2_array.id}", [result.length].pack('n'))
              result << mark2_array.encode
            end
          end

          def finalize(data)
            if data.placeholders.include?("gpos_#{mark1_coverage_table.id}")
              data.resolve_each("gsub_#{mark1_coverage_table.id}") do |placeholder|
                [data.length - placeholder.relative_to].pack('n')
              end

              data << mark1_coverage_table.encode
            end

            if data.placeholders.include?("gpos_#{mark2_coverage_table.id}")
              data.resolve_each("gpos_#{mark2_coverage_table.id}") do |placeholder|
                [data.length - placeholder.relative_to].pack('n')
              end

              data << mark2_coverage_table.encode
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
