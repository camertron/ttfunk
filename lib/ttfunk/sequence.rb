module TTFunk
  class Sequence
    include Enumerable

    attr_reader :data, :element_length, :reifier

    def initialize(data, element_length, &reifier)
      @data = data
      @element_length = element_length
      @reifier = reifier
    end

    def length
      data.length
    end

    def count
      length / element_length
    end

    def [](index)
      element_cache[index] ||= begin
        offset = index * element_length
        element = data[offset, element_length]
        reifier ? reifier.call(element) : element
      end
    end

    def each
      return to_enum(__method__) unless block_given?
      count.times { |i| yield self[i] }
    end

    private

    def element_cache
      @element_cache ||= {}
    end
  end
end
