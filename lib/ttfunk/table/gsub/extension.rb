module TTFunk
  class Table
    class Gsub
      class Extension < TTFunk::SubTable
        def self.create(file, _parent_table, offset)
          new(file, offset)
        end

        attr_reader :format, :extension_lookup_type, :extension_offset

        def sub_table
          @sub_table ||= LookupTable::SUB_TABLE_MAP[extension_lookup_type].create(
            file, self, table_offset + extension_offset
          )
        end

        def max_context
          sub_table.max_context
        end

        private

        def parse!
          @format, @extension_lookup_type, @extension_offset = read(8, 'nnN')
          @length = 8
        end
      end
    end
  end
end
