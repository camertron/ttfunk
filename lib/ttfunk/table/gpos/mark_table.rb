module TTFunk
  class Table
    class Gpos
      class MarkTable < TTFunk::SubTable
        attr_reader :mark_class, :mark_anchor_offset

        private

        def parse!
          @mark_class, @mark_anchor_offset = read(4, 'nn')
          @length = 4
        end
      end
    end
  end
end
