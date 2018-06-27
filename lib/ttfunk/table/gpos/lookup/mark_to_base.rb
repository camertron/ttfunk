module TTFunk
  class Table
    class Gpos
      module Lookup
        class MarkToBase < TTFunk::SubTable
          attr_reader :lookup_type
          attr_reader :format, :mark_coverage_offset, :base_coverage_offset
          attr_reader :mark_class_count, :mark_array_offset, :base_array_offset
          attr_reader :mark_array, :base_array

          def self.create(file, _parent_table, offset, lookup_type)
            new(file, offset, lookup_type)
          end

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

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
              result << Placeholder.new("gpos_#{mark_coverage_table.id}", length: 2, relative_to: 0)
              result << Placeholder.new("gpos_#{base_coverage_table.id}", length: 2, relative_to: 0)
              result << [mark_array.count].pack('n')
              result << Placeholder.new("gpos_#{mark_array.id}", length: 2, relative_to: 0)
              result << Placeholder.new("gpos_#{base_array.id}", length: 2, relative_to: 0)

              result.resolve_placeholder("gpos_#{mark_array.id}", [result.length].pack('n'))
              result << mark_array.encode

              result.resolve_placeholder("gpos_#{base_array.id}", [result.length].pack('n'))
              result << base_array.encode
            end
          end

          def finalize(data)
            if data.placeholders.include?("gpos_#{mark_coverage_table.id}")
              data.resolve_each("gsub_#{mark_coverage_table.id}") do |placeholder|
                [data.length - placeholder.relative_to].pack('n')
              end

              data << mark_coverage_table.encode
            end

            if data.placeholders.include?("gpos_#{base_coverage_table.id}")
              data.resolve_each("gpos_#{base_coverage_table.id}") do |placeholder|
                [data.length - placeholder.relative_to].pack('n')
              end

              data << base_coverage_table.encode
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
