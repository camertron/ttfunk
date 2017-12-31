module TTFunk
  module BinUtils
    def pack_int(arr, bit_width)
      value = 0

      arr.each_with_index do |element, index|
        value |= element << bit_width * index
      end

      value
    end

    def self.unpack_int(value, bit_width)
      num_elements = (Math.log2(value).ceil / bit_width).ceil + 1
      mask = 2 ** bit_width - 1

      Array.new(num_elements) do |i|
        (value >> bit_width * i) & mask
      end
    end
  end

  BinUtils.extend(BinUtils)
end
