module TTFunk
  class Table
    class Gpos
      module Lookup
        class PairAdjustment2 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :lookup_type
          attr_reader :format, :coverage_offset, :value_format1
          attr_reader :value_format2, :class_def1_offset
          attr_reader :class_def2_offset, :class1_tables

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

          def class_def1
            @class_def1 ||= Common::ClassDef.create(
              self, table_offset + class_def1_offset
            )
          end

          def class_def2
            @class_def2 ||= Common::ClassDef.create(
              self, table_offset + class_def2_offset
            )
          end

          def dependent_coverage_tables
            [coverage_table]
          end

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << Placeholder.new("gpos_#{coverage_table.id}", length: 2, relative_to: 0)
              result << [value_format1, value_format2].pack('n*')
              result << Placeholder.new("gpos_#{class_def1.id}", length: 2, relative_to: 0)
              result << Placeholder.new("gpos_#{class_def2.id}", length: 2, relative_to: 0)
              result << [class1_tables.count, class1_tables.first.count].pack('n*')

              class1_tables.each do |class2_array|
                class2_array.encode_to(result) do |class2|
                  class2.encode
                end
              end

              result.resolve_placeholder("gpos_#{class_def1.id}", [result.length].pack('n'))
              result << class_def1.encode

              result.resolve_placeholder("gpos_#{class_def2.id}", [result.length].pack('n'))
              result << class_def2.encode
            end
          end

          def finalize(data)
            if data.placeholders.include?("gsub_#{coverage_table.id}")
              data.resolve_each("gsub_#{coverage_table.id}") do |placeholder|
                [data.length - placeholder.relative_to].pack('n')
              end

              data << coverage_table.encode
            end
          end

          private

          def parse!
            @format, @coverage_offset, @value_format1, @value_format2,
              @class_def1_offset, @class_def2_offset, class1_count,
              class2_count = read(16, 'n8')

            @class1_tables = Array.new(class1_count) do
              Array.new(class2_count) do
                Class2.new(
                  file, io.pos, value_format1, value_format2, table_offset
                )
              end
            end

            @length = 16 + sum(class1_tables) do |class1_tables|
              sum(class1_tables, &:length)
            end
          end
        end
      end
    end
  end
end
