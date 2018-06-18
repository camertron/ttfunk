module TTFunk
  class Table
    module Common
      class CoverageTable2 < TTFunk::SubTable
        attr_reader :format, :range_tables

        def encode
          EncodedString.new do |result|
            result << [format, range_tables.count].pack('nn')
            range_tables.encode_to(result) do |range_table|
              [Placeholder.new("common_#{range_table.id}", length: 2)]
            end

            range_tables.each do |range_table|
              result.resolve_each("common_#{range_table.id}") do |_placeholder|
                [result.length].pack('n')
              end

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
