module TTFunk
  class Table
    class Gpos
      class MarkTable < TTFunk::SubTable
        attr_reader :mark_array_offset, :mark_class, :mark_anchor_offset

        def initialize(file, offset, mark_array_offset)
          @mark_array_offset = mark_array_offset
          super(file, offset)
        end

        def encode
          EncodedString.new do |result|
            result << [mark_class].pack('n')
            # this is eventually resolved by MarkArray
            result << anchor_table.placeholder
          end
        end

        def anchor_table
          @anchor_table ||= AnchorTable.create(
            file, self, mark_array_offset + mark_anchor_offset
          )
        end

        private

        def parse!
          @mark_class, @mark_anchor_offset = read(4, 'n*')
          @length = 4
        end
      end
    end
  end
end
