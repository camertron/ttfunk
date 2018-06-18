module TTFunk
  class Table
    class Gpos
      class MarkArray < TTFunk::SubTable
        attr_reader :marks

        private

        def parse!
          count = read(2, 'n').first

          @marks = ArraySequence.new(io, count) do
            MarkTable.new(file, io.pos, table_offset)
          end

          @length = 2 + marks.length
        end
      end
    end
  end
end
