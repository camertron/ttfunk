module TTFunk
  module BinUtils
    PACK_MAP = {
      'A' => 1,
      'C' => 1,
      'n' => 2,
      'N' => 4
    }

    def length_of(pack_format)
      len = 0
      last_format_char = nil

      pack_format.each_char do |char|
        if PACK_MAP.include?(char)
          last_format_char = char
          len += PACK_MAP[char]
        elsif char == '*'
          raise ArgumentError, "unbounded quantifiers (i.e. '*') are not supported."
        else
          # must be a numeric quantifier
          len += (char.to_i - 1) * PACK_MAP[last_format_char]
        end
      end

      len
    end

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

    # value can be a Rational, Float, Integer, etc
    # for best results, use a Rational
    def pack_f2dot14(value)
      # 16384 is a magic constant defined in the OTF spec for the f2dot14 format
      int = twos_comp(value.abs.to_i, 2) << 14
      frac = ((value - value.to_i) * 16384.0).to_i
      int | frac
    end

    # returns a Rational
    def unpack_f2dot14(value)
      # 16384 is a magic constant defined in the OTF spec for the f2dot14 format
      int = twos_comp(value >> 14, 2)
      frac = Rational(value & 0x3FFF, 16384.0)
      int + frac
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
