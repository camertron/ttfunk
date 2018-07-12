module TTFunk
  class Table
    class Gpos
      class PairSet < TTFunk::SubTable
        attr_reader :pair_value_tables, :lookup_table
        attr_reader :value_format1, :value_format2

        def initialize(file, offset, value_format1, value_format2, lookup_table)
          @value_format1 = value_format1
          @value_format2 = value_format2
          @lookup_table = lookup_table
          super(file, offset)
        end

        def encode
          EncodedString.new do |result|
            result << [pair_value_tables.count].pack('n')
            pair_value_tables.each do |pair_value_table|
              result << pair_value_table.encode
            end
          end
        end

        def finalize(data)
          pair_value_tables.each { |pvt| pvt.finalize(data) }
        end

        private

        def parse!
          count = read(2, 'n').first
          @pair_value_tables = ArraySequence.new(io, count) do
            PairValueTable.new(
              file,
              io.pos,
              value_format1,
              value_format2,
              lookup_table
            )
          end

          @length = 2 + pair_value_tables.length
        end
      end
    end
  end
end
