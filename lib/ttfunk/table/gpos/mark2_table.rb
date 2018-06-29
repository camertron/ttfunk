module TTFunk
  class Table
    class Gpos
      class Mark2Table < TTFunk::SubTable
        attr_reader :mark_class_count, :anchor_tables

        def initialize(file, offset, mark_class_count, mark2_array_offset)
          @mark_class_count = mark_class_count
          @mark2_array_offset = mark2_array_offset
          super(file, offset)
        end

        def encode
          EncodedString.new do |result|
            anchor_tables.encode_to(result) do |anchor_offset|
              [anchor_offset.placeholder]
            end

            anchor_tables.each do |anchor_offset|
              result.resolve_placeholder(anchor_offset.id, [result.length].pack('n'))
              result << anchor_offset.encode
            end
          end
        end

        private

        def parse!
          @anchor_tables = Sequence.from(io, mark_class_count, 'n') do |anchor_offset|
            AnchorTable.new(file, mark2_array_offset + anchor_offset)
          end

          @length = anchor_tables.length
        end
      end
    end
  end
end
