module TTFunk
  class Table
    class Gpos
      class Mark2Array < TTFunk::SubTable
        attr_reader :mark_class_count, :mark2_array_offset, :mark2s

        def initialize(file, offset, mark_class_count, mark2_array_offset)
          @mark_class_count = mark_class_count
          @mark2_array_offset = mark2_array_offset
          super(file, offset)
        end

        def encode
          EncodedString.new do |result|
            result << [mark2s.count].pack('n')
            mark2s.each { |mark2| result << mark2.encode }
          end
        end

        private

        def parse!
          count = read(2, 'n').first

          @mark2s = Array.new(count) do
            Mark2Table.new(file, io.pos, mark_class_count, mark2_array_offset)
          end

          @length = 2 + sum(mark2s, &:length)
        end
      end
    end
  end
end
