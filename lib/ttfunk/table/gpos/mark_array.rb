module TTFunk
  class Table
    class Gpos
      class MarkArray < TTFunk::SubTable
        attr_reader :marks

        private

        def parse!
          count = read(2, 'n').first
          @marks = Array.new(count) { MarkTable.new(file, io.pos) }
          @length = 2 + marks.length
        end
      end
    end
  end
end
