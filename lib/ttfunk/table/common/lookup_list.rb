module TTFunk
  class Table
    module Common
      class LookupList < TTFunk::SubTable
        LOOKUP_RECORD_LENGTH = 2

        attr_reader :records

        private

        def parse!
          count = read(2, 'n').first
          lookup_table_offset_array = io.read(count * LOOKUP_RECORD_LENGTH)

          @records = Sequence.new(lookup_table_offset_array, LOOKUP_RECORD_LENGTH) do |lookup_table_data|
            lookup_table_offset = lookup_table_data.unpack('n').first
            LookupTable.new(file, table_offset + lookup_table_offset)
          end

          @length = 2 + @records.length
        end
      end
    end
  end
end
