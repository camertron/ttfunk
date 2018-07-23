module TTFunk
  class Table
    class Gpos
      class MarkArray < TTFunk::SubTable
        attr_reader :marks

        def encode
          EncodedString.new do |result|
            result << [marks.count].pack('n')

            # the mark's anchor table is relative to the mark array (i.e. us),
            # which is why these gymnastics are necessary
            marks.each do |mark|
              result << mark.encode.unresolved_string
              result << Placeholder.new(mark.id, length: 2).tap do |ph|
                ph.position = result.length - 2
              end
            end

            marks.each do |mark|
              result.resolve_each(mark.id) { [result.length].pack('n') }
            end
          end
        end

        private

        def parse!
          count = read(2, 'n').first

          @marks = ArraySequence.new(io, count) do
            MarkTable.new(file, io.pos, table_offset)
          end

          @length = 2 + sum(marks, &:length)
        end
      end
    end
  end
end
