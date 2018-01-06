module TTFunk
  class Table
    module Common
      module Subst
        class Extension < TTFunk::SubTable
          def self.create(file, offset)
            new(file, offset)
          end

          attr_reader :format, :extension_lookup_type, :extension_offset

          def sub_table
            @sub_table ||= LookupTable::SUB_TABLE_MAP[extension_lookup_type].create(
              file, table_offset + extension_offset
            )
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
end
