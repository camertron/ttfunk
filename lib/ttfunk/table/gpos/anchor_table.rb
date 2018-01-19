module TTFunk
  class Table
    class Gpos
      class AnchorTable < TTFunk::SubTable
          FORMAT_MAP = {
            1 => AnchorTable1, 2 => AnchorTable2, 3 => AnchorTable3
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
