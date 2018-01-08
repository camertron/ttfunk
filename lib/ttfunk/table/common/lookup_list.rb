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
            result << tables.encode do |table|
              [ph(:common, table.id, 2)]
            end

            tables.each do |table|
              result.resolve_placeholder(:common, table.id, [result.length].pack('n'))
              result << table.encode
            end
          end
        end

        private

        def parse!
          count = read(2, 'n').first

          @tables = Sequence.from(io, count, 'n') do |lookup_table_offset|
            lookup_table_class.new(file, table_offset + lookup_table_offset)
          end

          @length = 2 + @tables.length
        end
      end
    end
  end
end
