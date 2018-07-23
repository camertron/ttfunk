module TTFunk
  class Table
    class Gpos
      class BaseArray < TTFunk::SubTable
        attr_reader :mark_class_count, :bases

        def initialize(file, offset, mark_class_count)
          @mark_class_count = mark_class_count
          super(file, offset)
        end

        def encode
          EncodedString.new do |result|
            result << [bases.size].pack('n')
            bases.each { |base| result << base.encode }
          end
        end

        private

        def parse!
          count = read(2, 'n').first

          @bases = Array.new(count) do
            BaseTable.new(file, io.pos, table_offset, mark_class_count)
          end

          @length = 2 + sum(bases, &:length)
        end
      end
    end
  end
end
