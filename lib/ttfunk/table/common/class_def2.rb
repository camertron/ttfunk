module TTFunk
  class Table
    module Common
      class ClassDef2 < TTFunk::SubTable
        attr_reader :format, :class_range_tables

        def encode
          EncodedString.create do |result|
            result.write([format, class_range_tables.count], 'nn')
            class_range_tables.encode_to(result) do |class_range_table|
              [ph(:common, class_range_table.id, length: 2)]
            end

            class_range_tables.each do |class_range_table|
              result.resolve_placeholders(
                :common, class_range_table.id, [result.length].pack('n')
              )

              result << class_range_table.encode
            end
          end
        end

        private

        def parse!
          @format, count = read(4, 'n')

          @class_range_tables = Sequence.new(io, count, 'n') do |class_range_offset|
            ClassRangeTable.new(table_offset + class_range_offset)
          end

          @length = 4 + class_range_tables.length
        end
      end
    end
  end
end
