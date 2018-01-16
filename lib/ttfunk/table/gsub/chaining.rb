module TTFunk
  class Table
    class Gsub
      class Chaining
        FORMAT_MAP = {
          1 => Chaining1, 2 => Chaining2, 3 => Chaining3
        }

        def self.create(file, parent_table, offset, lookup_type)
          format = parent_table.parse_from(offset) do
            parent_table.read(2, 'n').first
          end

          FORMAT_MAP[format].new(parent_table.file, offset, lookup_type)
        end
      end
    end
  end
end

