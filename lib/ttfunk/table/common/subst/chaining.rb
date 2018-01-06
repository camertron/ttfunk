module TTFunk
  class Table
    module Common
      module Subst
        class Chaining
          FORMAT_MAP = {
            1 => Chaining1, 2 => Chaining2, 3 => Chaining3
          }

          def self.create(lookup_table, offset)
            format = lookup_table.parse_from(offset) do
              lookup_table.read(2, 'n').first
            end

            FORMAT_MAP[format].new(lookup_table.file, offset)
          end
        end
      end
    end
  end
end

