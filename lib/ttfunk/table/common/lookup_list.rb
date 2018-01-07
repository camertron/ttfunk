module TTFunk
  class Table
    module Common
      class LookupList < TTFunk::SubTable
        attr_reader :lookup_table_class, :tables

        def initialize(file, offset, lookup_table_class)
          @lookup_table_class = lookup_table_class
          super(file, offset)
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
