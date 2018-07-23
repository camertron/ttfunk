module TTFunk
  class Table
    module Common
      class CoverageTable
        FORMAT_MAP = {
          1 => CoverageTable1, 2 => CoverageTable2
        }

        def self.create(file, parent_table, offset)
          format = parent_table.parse_from(offset) do
            parent_table.read(2, 'n').first
          end

          FORMAT_MAP[format].new(parent_table.file, offset)
        end
      end
    end
  end
end
