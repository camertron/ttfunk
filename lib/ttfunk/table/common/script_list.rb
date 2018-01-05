module TTFunk
  class Table
    module Common
      class ScriptList < TTFunk::SubTable
        attr_reader :tables

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
