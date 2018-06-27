module TTFunk
  class Table
    class Gpos
      class MarkArray < TTFunk::SubTable
        attr_reader :marks

        private

        def parse!
          count = read(2, 'n').first

          @marks = Array.new(count) do
            MarkTable.new(file, io.pos, table_offset)
          end

          @length = 2 + sum(marks, &:length)
        end
      end
    end
  end
end
