module TTFunk
  class Table
    module Common
      class ScriptList < TTFunk::SubTable
        attr_reader :tables

        def encode(old2new_features)
          EncodedString.new do |result|
            result << [tables.count].pack('n')
            tables.encode_to(result) do |table|
              [table.tag, table.placeholder]
            end

            tables.each do |table|
              result.resolve_placeholder(table.id, [result.length].pack('n'))
              result << table.encode(old2new_features)
            end
          end
        end

        def length
          @length + sum(tables, &:length)
        end

        private

        def parse!
          count = read(2, 'n').first

          @tables = Sequence.from(io, count, 'A4n') do |tag, script_table_offset|
            ScriptTable.new(file, tag, table_offset + script_table_offset)
          end

          @length = 2 + tables.length
        end
      end
    end
  end
end
