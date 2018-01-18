module TTFunk
  class Table
    class Gpos
      class BaseArray < TTFunk::SubTable
        attr_reader :mark_class_count, :bases

        def initialize(file, offset, mark_class_count)
          @mark_class_count = mark_class_count
          super(file, offset)
        end

        private

        def parse!
          count = read(2, 'n').first
          @bases = Array.new(count) { BaseTable.new(file, pos, mark_class_count) }
          @length = 2 + bases.length
        end
      end
    end
  end
end
