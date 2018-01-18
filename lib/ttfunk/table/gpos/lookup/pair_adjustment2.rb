module TTFunk
  class Table
    class Gpos
      module Lookup
        class PairAdjustment2 < TTFunk::SubTable
          private

          def parse!
            @format, @coverage_offset, @value_format1, @value_format2,
              @class_def1_offset, @class_def2_offset, class1_count,
              class2_count = read(16, 'n8')

            @class1_tables = Array.new(class1_count) do
              Array.new(class2_count) { Class2.new(file, io.pos) }
            end

            @length = 16 + class1_tables.inject(0) do |sum1, class1_tables|
              sum1 + class1_tables.inject(0) do |sum2, class2_table|
                sum2 + class2_table.length
              end
            end
          end
        end
      end
    end
  end
end
