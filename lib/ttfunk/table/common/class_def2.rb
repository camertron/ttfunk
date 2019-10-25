# frozen_string_literal: true

module TTFunk
  class Table
    module Common
      class ClassDef2 < TTFunk::SubTable
        attr_reader :format, :class_range_tables

        def encode
          EncodedString.new do |result|
            result << [format, class_range_tables.count].pack('nn')

            class_range_tables.each do |class_range_table|
              result << class_range_table.encode
            end
          end
        end

        private

        def parse!
          @format, count = read(4, 'nn')
          @class_range_tables = ClassRangeTable.create_sequence(io, count)
          @length = 4 + sum(class_range_tables, &:length)
        end
      end
    end
  end
end
