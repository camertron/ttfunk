module TTFunk
  class Table
    module Common
      class ScriptList < TTFunk::SubTable
        SCRIPT_TABLE_RECORD_LENGTH = 6

        attr_reader :tables

        private

        def parse!
          count = read(2, 'n').first
          script_table_array = io.read(count * SCRIPT_TABLE_RECORD_LENGTH)

          @tables = Sequence.new(script_table_array, SCRIPT_TABLE_RECORD_LENGTH) do |script_table_data|
            tag, script_table_offset = script_table_data.unpack('A4n')
            ScriptTable.new(file, tag, table_offset + script_table_offset)
          end

          @length = 2 + tables.length
        end
      end
    end
  end
end
