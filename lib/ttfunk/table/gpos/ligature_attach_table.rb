module TTFunk
  class Table
    class Gpos
      class LigatureAttachTable < TTFunk::SubTable
        attr_reader :mark_class_count, :components

        def initialize(file, offset, mark_class_count)
          @mark_class_count = mark_class_count
          super(file, offset)
        end

        def encode
          EncodedString.new do |result|
            result << [components.size].pack('n')
            components.each { |component| result << component.encode }
          end
        end

        private

        def parse!
          count = read(2, 'n').first

          @components = Array.new(count) do
            ComponentTable.new(file, io.pos, table_offset, mark_class_count)
          end

          @length = 2 + components.length
        end
      end
    end
  end
end
