require 'tsort'

module TTFunk
  class Table
    module Common
      class LookupList < TTFunk::SubTable
        attr_reader :lookup_table_class, :tables

        def initialize(file, offset, lookup_table_class)
          @lookup_table_class = lookup_table_class
          super(file, offset)
        end

        def encode
          EncodedString.create do |result|
            # result.write(tables.count, 'n')
            num_to_encode = 45
            result.write(num_to_encode, 'n')
            counter = 0
            tables.encode_to(result) do |table|
              next if counter >= num_to_encode
              [ph(:common, table.id, length: 2)].tap { counter += 1 }
            end

            tables.each.with_index do |table, idx|
              next if idx >= num_to_encode
              result.resolve_placeholders(:common, table.id, [result.length].pack('n'))
              result << table.encode
            end
          end
        end

        def finalize(data)
          tables.each { |table| table.finalize(data) }
        end

        private

        def parse!
          count = read(2, 'n').first

          @tables = Sequence.from(io, count, 'n') do |lookup_table_offset|
            lookup_table_class.new(
              file,
              table_offset + lookup_table_offset,
              lookup_table_class::SUB_TABLE_MAP
            )
          end

          @length = 2 + tables.length
        end
      end
    end
  end
end
