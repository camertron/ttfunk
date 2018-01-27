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

          @bases = Sequence.from(io, count, "n#{mark_class_count}") do |anchor_offsets|
            BaseTable.new(file, anchor_offsets)
          end

          @length = 2 + bases.length
        end
      end
    end
  end
end
