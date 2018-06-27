module TTFunk
  class Table
    class Gpos
      class Mark2Array < TTFunk::SubTable
        attr_reader :mark_class_count, :mark2_array_offset, :mark2s

        def initialize(file, offset, mark_class_count, mark2_array_offset)
          @mark_class_count = mark_class_count
          @mark2_array_offset = mark2_array_offset
          super(file, offset)
        end

        private

        def parse!
          count = read(2, 'n').first
          @mark2s = Array.new(count) do
            Mark2Table.new(file, io.pos, mark_class_count, mark2_array_offset)
          end
          @length = 2 + sum(mark2s, &:length)
        end
      end
    end
  end
end
