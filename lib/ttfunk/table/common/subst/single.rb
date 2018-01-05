module TTFunk
  class Table
    module Common
      module Subst
        class Single
          FORMAT_MAP = {
            1 => Single1, 2 => Single2
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
