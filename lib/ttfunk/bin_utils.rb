module TTFunk
  module BinUtils
    # assumes big-endian
    def stitch_int(arr, bit_width:)
      value = 0

      arr.each_with_index do |element, index|
        value |= element << bit_width * index
      end

      value
    end

    # assumes big-endian
    def slice_int(value, bit_width:, slice_count:)
      mask = 2**bit_width - 1

      Array.new(slice_count) do |i|
        (value >> bit_width * i) & mask
      end
    end

    def twos_comp_to_int(num, bit_width:)
      if num >> (bit_width - 1) == 1
        # we want all ones
        mask = (2**bit_width) - 1

        # find 2's complement, i.e. flip bits (xor with mask) and add 1
        -((num ^ mask) + 1)
      else
        num
      end
    end

    # turns a sequence of values into a series of ruby ranges
    def rangify(values)
      start = values.first

      [].tap do |ranges|
        values.each_cons(2) do |first, second|
          if second - first != 1
            ranges << [start, first - start]
            start = second
          end
        end

        ranges << [start, values.last - start]
      end
    end

    # value can be a Rational, Float, Integer, etc
    # for best results, use a Rational
    def encode_f2dot14(value)
      # 16384 is a magic constant defined in the OTF spec for the f2dot14 format
      int = twos_comp(value.abs.to_i, 2) << 14
      frac = ((value - value.to_i) * 16384.0).to_i
      int | frac
    end

    # returns a Rational
    def decode_f2dot14(value)
      # 16384 is a magic constant defined in the OTF spec for the f2dot14 format
      int = twos_comp(value >> 14, 2)
      frac = Rational(value & 0x3FFF, 16384.0)
      int + frac
    end
  end

  BinUtils.extend(BinUtils)
end
