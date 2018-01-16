module TTFunk
  class Table
    module Common
      class CoverageTable2 < TTFunk::SubTable
        attr_reader :format, :range_tables

        def encode
          EncodedString.create do |result|
            result.write([format, range_tables.count], 'nn')
            range_tables.encode_to(result) do |range_table|
              [ph(:common, range_table.id, length: 2, relative_to: 0)]
            end

            range_tables.each do |range_table|
              result.resolve_placeholders(
                :common, range_table.id, [result.length].pack('n')
              )

              result << range_table.encode
            end
          end
        end

        def length
          @length + sum(range_tables, &:length)
        end

        private

        def parse!
          @format, count = read(4, 'nn')

          @range_tables = Sequence.from(io, count, 'n') do |range_table_offset|
            RangeTable.new(file, table_offset + range_table_offset)
          end

          @length = 4 + range_tables.length
        end
      end
    end
  end
end
