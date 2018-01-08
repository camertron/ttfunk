module TTFunk
  class Table
    module Common
      class CoverageTable2 < TTFunk::SubTable
        attr_reader :format, :range_tables

        def encode
          EncodedString.create do |result|
            result.write(range_tables.count, 'n')
            result << range_tables.encode do |range_table|
              [ph(:common, range_table.id, 2)]
            end

            range_tables.each do |range_table|
              result.resolve_placeholder(
                :common, range_table.id, [result.length].pack('n')
              )

              result << range_table.encode
            end
          end
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
