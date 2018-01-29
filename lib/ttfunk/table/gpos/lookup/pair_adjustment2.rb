module TTFunk
  class Table
    class Gpos
      module Lookup
        class PairAdjustment2 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :value_format1
          attr_reader :value_format2, :class_def1_offset
          attr_reader :class_def2_offset, :class1_tables

          private

          def parse!
            @format, @coverage_offset, @value_format1, @value_format2,
              @class_def1_offset, @class_def2_offset, class1_count,
              class2_count = read(16, 'n8')

            @class1_tables = Array.new(class1_count) do
              ArraySequence.new(io, class2_count) do
                Class2.new(
                  file, io.pos, value_format1, value_format2, table_offset
                )
              end
            end

            @length = 16 + class1_tables.inject(0) do |sum, class1_tables|
              sum + class1_tables.length
            end
          end
        end
      end
    end
  end
end
