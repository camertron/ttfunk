module TTFunk
  class Table
    class Gpos
      class Mark2Array < TTFunk::SubTable
        attr_reader :mark_class_count, :mark2s

        def initialize(file, offset, mark_class_count)
          @mark_class_count = mark_class_count
          super(file, offset)
        end

        private

        def parse!
          count = read(2, 'n').first
          @mark2s = Array.new(count) { Mark2Table.new(file, io.pos) }
          @length = 2 + mark2s.length
        end
      end
    end
  end
end
