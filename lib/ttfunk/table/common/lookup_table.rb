module TTFunk
  class Table
    module Common
      class LookupTable < TTFunk::SubTable
        attr_reader :lookup_type, :lookup_flag, :sub_tables
        attr_reader :mark_filtering_set

        private

        def parse!
          @lookup_type, @lookup_flag, count = read(6, 'nnn')

          @sub_tables = Sequence.from(io, count, 'n') do |sub_table_offset|
            SUB_TABLE_MAP[lookup_type].create(file, self, table_offset + sub_table_offset)
          end

          @mark_filtering_set = read(2, 'n')
          @length = 8 + sub_tables.length
        end
      end
    end
  end
end
