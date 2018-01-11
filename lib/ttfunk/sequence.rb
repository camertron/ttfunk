module TTFunk
  class Sequence
    include Enumerable

    attr_reader :data, :count, :pack_format, :reifier, :element_length

    def self.from(io, count, pack_format, &reifier)
      element_length = PackFormat.length_of(pack_format)
      data = io.read(count * element_length)
      new(data, count, pack_format, element_length, &reifier)
    end

    def initialize(data, count, pack_format, element_length, &reifier)
      @data = data
      @count = count
      @pack_format = pack_format
      @element_length = element_length
      @reifier = reifier
    end

    def encode
      return to_enum(__method__) unless block_given?

      EncodedString.new.tap do |result|
        each do |element|
          values = Array(block_given? ? yield(element) : element)

          values.each_with_index do |value, idx|
            if value.is_a?(Placeholder)
              result << value
            else
              result << [value].pack(pack_segments[idx])
            end
          end
        end
      end
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

    def pack_segments
      @pack_segments ||= PackFormat.split(pack_format)
    end

    def element_cache
      @element_cache ||= {}
    end
  end
end
