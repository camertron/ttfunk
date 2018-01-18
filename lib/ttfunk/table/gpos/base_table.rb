module TTFunk
  class Table
    class Gpos
      class BaseTable < TTFunk::SubTable
        attr_reader :mark_class_count, :base_anchor_offsets

        def initialize(file, offset, mark_class_count)
          @mark_class_count = mark_class_count
          super(file, offset)
        end

        private

        def parse!
          @base_anchor_offsets = Sequence.new(io, mark_class_count, 'n')
          @length = base_anchor_offsets.length
        end
      end
    end
  end
end
