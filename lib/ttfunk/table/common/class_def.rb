module TTFunk
  class Table
    module Common
      class ClassDef
        FORMAT_MAP = {
          1 => ClassDef1, 2 => ClassDef2
        }

        def self.create(parent_table, offset)
          format = parent_table.parse_from(offset) do
            parent_table.read(2, 'n').first
          end

          FORMAT_MAP[format].new(parent_table.file, offset)
        end
      end
    end
  end
end
