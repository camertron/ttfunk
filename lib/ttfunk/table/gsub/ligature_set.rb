module TTFunk
  class Table
    class Gsub
      class LigatureSet < TTFunk::SubTable
        attr_reader :tables

        def encode
          EncodedString.create do |result|
            result.write(tables.count, 'n')
            tables.encode_to(result) do |table|
              [ph(:gsub, table.id, length: 2)]
            end

            tables.each do |table|
              result.resolve_placeholders(
                :gsub, table.id, [result.length].pack('n')
              )

              result << table.encode
            end
          end
        end

        def length
          @length + sum(tables, &:length)
        end

        private

        def parse!
          count = read(2, 'n').first

          @tables = Sequence.from(io, count, 'n') do |ligature_table_offset|
            LigatureTable.new(file, table_offset + ligature_table_offset)
          end

          @length = 2 + tables.length
        end
      end
    end
  end
end
