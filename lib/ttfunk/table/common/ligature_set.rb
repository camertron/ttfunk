module TTFunk
  class Table
    module Common
      class LigatureSet < TTFunk::SubTable
        attr_reader :tables

        def encode
          EncodedString.create do |result|
            result.write(tables.count, 'n')
            result << tables.encode do |table|
              [ph(:common, table.id, 2)]
            end

            tables.each do |table|
              result.resolve_placeholder(
                :common, table.id, [result.length].encode('N')
              )

              result << table.encode
            end
          end
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
