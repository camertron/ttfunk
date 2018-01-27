module TTFunk
  class Table
    class Gpos
      class BaseTable < TTFunk::SubTable
        attr_reader :base_anchor_offsets, :base_array_offset

        def initialize(file, base_array_offset, base_anchor_offsets)
          @base_array_offset = base_array_offset
          @base_anchor_offsets = base_anchor_offsets
          @length = base_anchor_offsets.length * 2

          super(file, base_array_offset)
        end

        def anchor_tables
          @anchor_tables ||= Array.new(base_anchor_offsets.length) do |i|
            AnchorTable.create(file, self, base_array_offset + base_anchor_offsets[i])
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
