module TTFunk
  class Table
    class Gpos
      class ComponentTable < TTFunk::SubTable
        attr_reader :ligature_attach_offset, :mark_class_count, :anchor_tables

        def initialize(file, offset, ligature_attach_offset, mark_class_count)
          @ligature_attach_offset = ligature_attach_offset
          @mark_class_count = mark_class_count
          super(file, offset)
        end

        def encode
          EncodedString.new do |result|
            anchor_tables.encode_to(result) do |anchor_table|
              [anchor_table.placeholder]
            end

            anchor_tables.each do |anchor_table|
              result.resolve_placeholder(anchor_table.id, [result.length].pack('n'))
              result << anchor_table.encode
            end
          end
        end

        private

        def parse!
          @anchor_tables = Sequence.from(io, mark_class_count, 'n') do |anchor_offset|
            AnchorTable.create(file, self, ligature_attach_offset + anchor_offset)
          end

          @length = anchor_tables.length
        end
      end
    end
  end
end
