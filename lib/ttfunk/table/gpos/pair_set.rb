module TTFunk
  class Table
    class Gpos
      class PairSet < TTFunk::SubTable
        attr_reader :pair_value_tables, :lookup_table_offset
        attr_reader :value_format1, :value_format2

        def initialize(file, offset, value_format1, value_format2, lookup_table_offset)
          @value_format1 = value_format1
          @value_format2 = value_format2
          @lookup_table_offset = lookup_table_offset
          super(file, offset)
        end

        def encode
          EncodedString.new do |result|
            result << [pair_value_tables.count].pack('n')
            pair_value_tables.encode_to(result) do |pair_value_table|
              [pair_value_table.placeholder]
            end

            pair_value_tables.each do |pair_value_table|
              result.resolve_each(pair_value_table.id) { [result.length].pack('n') }
              result << pair_value_table.encode
            end
          end
        end

        private

        def parse!
          count = read(2, 'n').first
          @pair_value_tables = Sequence.from(io, count, 'n') do |pair_value_table_offset|
            PairValueTable.new(
              file,
              table_offset + pair_value_table_offset,
              value_format1,
              value_format2,
              lookup_table_offset
            )
          end
        end
      end
    end
  end
end
