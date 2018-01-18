module TTFunk
  class Table
    class Gpos
      class ComponentTable < TTFunk::SubTable
        attr_reader :mark_class_count, :ligature_anchor_offsets

        def initialize(file, offset, mark_class_count, lig_attach_offset)
          @mark_class_count = mark_class_count
          @lig_attach_offset = lig_attach_offset
          super(file, offset)
        end

        private

        def parse!
          @ligature_anchor_offsets = Sequence.from(io, mark_class_count, 'n') do |lig_anchor_offset|
            CompoentTable.new(file, lig_attach_offset + lig_anchor_offset)
          end

          @length = ligature_anchor_offsets.length
        end
      end
    end
  end
end
