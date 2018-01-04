module TTFunk
  class Table
    module Common
      class LookupTable < TTFunk::SubTable
        SUB_TABLE_OFFSET_LENGTH = 2

        attr_reader :lookup_type, :lookup_flag, :sub_tables
        attr_reader :mark_filtering_set

        private

        def parse!
          @lookup_type, @lookup_flag, count = read(6, 'nnn')
          sub_table_offset_data = io.read(count * SUB_TABLE_OFFSET_LENGTH)

          @sub_tables = Sequence.new(sub_table_offset_data, SUB_TABLE_OFFSET_LENGTH) do |sub_table_offset|
            case lookup_type
              when 1
                Subst::Single.create(self, table_offset + sub_table_offset)
              when 2
                Subst::Multiple.create(self, table_offset + sub_table_offset)
              # when... @TODO moar
            end
          end

          @mark_filtering_set = read(2, 'n')
          @length = 8 + sub_tables.length
        end
      end
    end
  end
end
