module TTFunk
  class Table
    module Common
      class LookupList < TTFunk::SubTable
        include Enumerable

        LOOKUP_RECORD_LENGTH = 2

        attr_reader :count

        def each
          return to_enum(__method__) unless block_given?
          count.times { |i| yield self[i] }
        end

        def [](index)
          lookup_tables[index] ||= begin
            offset = index * LOOKUP_RECORD_LENGTH
            lookup_offset = @raw_record_array[offset, LOOKUP_RECORD_LENGTH].unpack('n').first
            LookupTable.new(file, table_offset + lookup_offset)
          end
        end

        private

        def parse!
          @count = read(2, 'n').first
          @raw_record_array = io.read(count * LOOKUP_RECORD_LENGTH)
          @length = 2 + @raw_record_array.length
        end

        def lookup_tables
          @lookup_tables ||= {}
        end
      end
    end
  end
end
