module TTFunk
  class Table
    class Gpos
      class BaseTable < TTFunk::SubTable
        attr_reader :base_array_offset, :mark_class_count
        attr_reader :anchor_tables

        def initialize(file, offset, base_array_offset, mark_class_count)
          @base_array_offset = base_array_offset
          @mark_class_count = mark_class_count
          super(file, offset)
        end

        private

        def parse!
          @anchor_tables = Sequence.from(io, mark_class_count, 'n') do |anchor_offset|
            AnchorTable.create(file, self, table_offset + anchor_offset)
          end

          @length = anchor_tables.length
        end
      end
    end
  end
end
