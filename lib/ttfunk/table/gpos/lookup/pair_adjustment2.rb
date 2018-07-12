module TTFunk
  class Table
    class Gpos
      module Lookup
        class PairAdjustment2 < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :value_format1
          attr_reader :value_format2, :class_def1_offset
          attr_reader :class_def2_offset, :class1_tables

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

          # @TODO: added for debugging, but do we need it?
          def value_tables
            class1_tables.flat_map do |cl2s|
              cl2s.flat_map { |cl2| [cl2.value_record1, value_record2].compact }
            end
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format].pack('n')
              result << coverage_table.placeholder_relative_to(id)
              result << [value_format1, value_format2].pack('n*')
              result << class_def1.placeholder
              result << class_def2.placeholder
              result << [class1_tables.count, class1_tables.first.count].pack('n*')

              class1_tables.each do |class2_array|
                class2_array.each do |class2|
                  result << class2.encode
                end
              end

              result.resolve_placeholder(class_def1.id, [result.length].pack('n'))
              result << class_def1.encode

              result.resolve_placeholder(class_def2.id, [result.length].pack('n'))
              result << class_def2.encode
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
                  file, io.pos, value_format1, value_format2, self
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
