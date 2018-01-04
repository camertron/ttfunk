module TTFunk
  class Table
    module Common
      module Subst
        class Single
          def self.create(lookup_table, offset)
            format = lookup_table.parse_from(offset) do
              lookup_table.read(2, 'n').first
            end

            case format
              when 1
                Single1.new(lookup_table.file, offset)
              when 2
                Single2.new(lookup_table.file, offset)
            end
          end
        end
      end
    end
  end
end
