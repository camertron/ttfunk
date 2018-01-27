module TTFunk
  class Table
    class Gpos
      class ComponentTable < TTFunk::SubTable
        attr_reader :ligature_anchor_offsetsm :ligature_attach_offset

        def initialize(file, ligature_anchor_offsets, ligature_attach_offset)
          @ligature_anchor_offsets = ligature_anchor_offsets
          @ligature_attach_offset = ligature_attach_offset
          @length = ligature_anchor_offsets.length * 2

          super(file, offset)
        end

        def anchor_tables
          @anchor_tables ||= Array.new(ligature_anchor_offsets.length) do |i|
            AnchorTable.create(file, self, ligature_attach_offset + ligature_anchor_offsets[i])
          end
        end

        private

        def parse!
          # no-op
        end
      end
    end
  end
end
