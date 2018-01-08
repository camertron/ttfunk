module TTFunk
  module PackFormat
    PACK_MAP = {
      'A' => 1,
      'C' => 1,
      'n' => 2,
      'N' => 4
    }

    def length_of(pack_format)
      split(pack_format).inject(0) do |sum, part|
        fmt_char, length = part.chars
        sum + PACK_MAP[fmt_char] * (length || '1').to_i
      end
    end

    def split(pack_format)
      arr = []

      pack_format.each_char do |char|
        if PACK_MAP.include?(char)
          arr << char
        elsif char == '*'
          raise ArgumentError, "unbounded quantifiers (i.e. '*') are not supported."
        else
          # must be a numeric quantifier
          arr[arr.length - 1] += char
        end
      end

      arr
    end
  end

  PackFormat.extend(PackFormat)
end
