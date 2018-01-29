module TTFunk
  class ArraySequence
    include Enumerable

    def initialize(io, count, &block)
      @elements = Array.new(count) do
        block.call.tap { |obj| io.pos += obj.length }
      end
    end

    def length
      @elements.inject(0) { |sum, elem| sum + elem.length }
    end

    def [](index)
      @elements[index]
    end

    def each(&block)
      @elements.each(&block)
    end
  end
end
