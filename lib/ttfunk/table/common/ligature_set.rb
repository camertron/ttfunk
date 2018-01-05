module TTFunk
  class Table
    module Common
      class LigatureSet < TTFunk::SubTable
        attr_reader :tables

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
