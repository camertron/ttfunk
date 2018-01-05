module TTFunk
  class Sequence
    include Enumerable

    attr_reader :data, :count, :pack_format, :reifier, :element_length

    def self.from(io, count, pack_format, &reifier)
      element_length = BinUtils.length_of(pack_format)
      data = io.read(count * element_length)
      binding.pry
      new(data, count, pack_format, element_length, &reifier)
    end

    def initialize(data, count, pack_format, element_length, &reifier)
      @data = data
      @count = count
      @pack_format = pack_format
      @element_length = element_length
      @reifier = reifier
    end

    def length
      data.length
    end

    def [](index)
      element_cache[index] ||= begin
        offset = index * element_length
        element_parts = data[offset, element_length].unpack(pack_format)

        if reifier
          reifier.call(*element_parts)
        else
          element_parts.size == 1 ? element_parts.first : element_parts
        end
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
