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
            result.write(tables.count, 'n')
            tables.encode_to(result) do |table|
              [ph(:common, table.id, length: 2)]
            end

            tables.each do |table|
              result.resolve_placeholders(:common, table.id, [result.length].pack('n'))
              result << table.encode
            end
          end
        end

        def finalize(data)
          tables.each { |table| table.finalize(data) }
          tables.each { |table| table.finalize_sub_tables(data) }
        end

        def length
          @length + sum(tables, &:length)
        end

        private

        def parse!
          count = read(2, 'n').first

          @tables = Sequence.from(io, count, 'n') do |lookup_table_offset|
            lookup_table_class.new(
              file,
              table_offset + lookup_table_offset,
              lookup_table_class
            )
          end

          @length = 2 + tables.length
        end
      end
    end
  end
end
