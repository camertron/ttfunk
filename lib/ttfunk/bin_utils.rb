module TTFunk
  module BinUtils
    def pack_int(arr, bit_width)
      value = 0

      arr.each_with_index do |element, index|
        value |= element << bit_width * index
      end

      value
    end

    def unpack_int(value, bit_width)
      return [0] if value == 0
      num_elements = (Math.log2(value).ceil / bit_width).ceil + 1
      mask = 2 ** bit_width - 1

      Array.new(num_elements) do |i|
        (value >> bit_width * i) & mask
      end
    end


    def twos_comp(num, bit_len)
      if num >> (bit_len - 1) == 1
        # we want all ones
        mask = (2 ** bit_len) - 1

        # find 2's complement, i.e. flip bits (xor with mask) and add 1
        -((num ^ mask) + 1)
      else
        num
      end
    end
  end

  BinUtils.extend(BinUtils)
end
