module TTFunk
  class Table
    class Gpos
      class Mark2Table < TTFunk::SubTable
        attr_reader :mark_class_count, :anchor_offsets

        def initialize(file, offset, mark_class_count, mark2_array_offset)
          @mark_class_count = mark_class_count
          @mark2_array_offset = mark2_array_offset
          super(file, offset)
        end

        private

        def parse!
          @anchor_offsets = Sequence.from(io, mark_class_count, 'n') do |anchor_offset|
            AnchorTable.new(file, mark2_array_offset + anchor_offset)
          end
        end
      end
    end
  end
end
