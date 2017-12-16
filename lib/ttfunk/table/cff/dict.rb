require 'bigdecimal'

module TTFunk
  class Table
    class Cff < TTFunk::Table
      class Dict < TTFunk::Table::Cff::CffTable
        include Enumerable

        def [](operator)
          @dict[operator]
        end

        def each(&block)
          @dict.each(&block)
        end

        alias_method :each_pair, :each

        def encode
          ''.tap do |result|
            result << [length].pack('C')

            each_with_index do |(operator, operands), idx|
              operands.each { |operand| result << encode_operand(operand) }
              result << encode_operator(operator)
            end
          end
        end

        private

        def encode_operator(operator)
          if operator >= 1200
            [12, operator - 1200].pack('C*')
          else
            [operator].pack('C')
          end
        end

        def encode_operand(operand)
          bytes = case operand
            when Integer
              encode_integer(operand)
            when Float, BigDecimal
              encode_float(operand)
            when Real
              encode_real(operand)
            else
              # @TODO, raise an error?
          end

          bytes.pack('C*')
        end

        def encode_integer(int)
          case int
            when -107..107
              [int + 139]

            when 108..1131
              int -= 108
              [(int >> 8) + 247, int & 0xFF]

            when -1131..-108
              int = -int - 108
              [(int >> 8) + 251, int & 0xFF]

            # @TODO
            # For some reason none of the integers in noto sans have been encoded using three
            # bytes. Feel free to uncomment this code when otf support is stable.

          #   when -32768..32767
          #     [28, (int >> 8) & 0xFF, int & 0xFF]

            else
              [
                29,
                (int >> 24) & 0xFF,
                (int >> 16) & 0xFF,
                (int >> 8) & 0xFF,
                int & 0xFF
              ]
          end
        end

        def encode_float(float)
          pack_decimal_nibbles(encode_base(float))
        end

        def encode_real(real)
          base_bytes = encode_base(real.base)
          exp_bytes = encode_exponent(real.exponent)
          pack_decimal_nibbles(base_bytes + exp_bytes)
        end

        def encode_exponent(exp)
          return [] if exp.zero?
          [exp.positive? ? 0xB : 0xC, *encode_base(exp)]
        end

        def encode_base(base)
          base.to_s.each_char.with_object([]) do |char, ret|
            case char
              when '0'..'9'
                ret << char.to_i
              when '.'
                ret << 0xA
              when '-'
                ret << 0xE
              else
                break ret
            end
          end
        end

        def pack_decimal_nibbles(nibbles)
          packed = [30]

          nibbles.each_slice(2).each do |(high_nb, low_nb)|
            # low_nb can be nil if nibbles contains an odd number of elements
            low_nb ||= 0xF
            packed << (high_nb << 4 | low_nb)
          end

          packed << 0xFF if nibbles.size.even?
          packed
        end

        def parse!
          @dict = {}
          operands = []
          operator = nil

          # @length can be set via the constructor, so only read a length if @length
          # hasn't already been set
          @length ||= read(1, 'C').first

          while io.pos < table_offset + length
            case b_zero = read(1, 'C').first
              when 12
                operator = decode_two_byte_operator
                @dict[operator] = operands
                operands = []
              when 0..21
                @dict[b_zero] = operands
                operands = []
              when 28..30, 32..254
                operands << decode_operand(b_zero)
              else
                raise RuntimeError, "dict byte value #{b_zero} is reserved"
            end
          end
        end

        def decode_two_byte_operator
          1200 + read(1, 'C').first
        end

        def decode_operand(b_zero)
          case b_zero
            when 30
              decode_real
            else
              decode_integer(b_zero)
          end
        end

        def decode_real
          mantissa = ''
          exponent = ''

          loop do
            current = read(1, 'C').first
            break if current == 0xFF

            high_nibble = current >> 4
            low_nibble = current & 0x0F  #  0b00001111

            [high_nibble, low_nibble].each do |nibble|
              case nibble
                when 0..9
                  (exponent.empty? ? mantissa : exponent) << nibble.to_s
                when 0xA
                  mantissa << '.'
                when 0xB
                  # take advantage of Integer#to_i not caring about whitespace
                  exponent << ' '
                when 0xC
                  exponent << '-'
                when 0xE
                  mantissa << '-'
              end
            end

            break if low_nibble == 0xF
          end

          Real.new(mantissa.to_f, exponent.to_i)
        end

        def decode_integer(b_zero)
          case b_zero
            when 32..246
              # 1 byte
              b_zero - 139

            when 247..250
              # 2 bytes
              b_one = read(1, 'C').first
              (b_zero - 247) * 256 + b_one + 108

            when 251..254
              # 2 bytes
              b_one = read(1, 'C').first
              -(b_zero - 251) * 256 - b_one - 108

            when 28
               # 2 bytes in number (3 total)
              b_one, b_two = read(2, 'C*')
              twos_comp(b_one << 8 | b_two, 2)

            when 29
              # 4 bytes in number (5 total)
              b_one, b_two, b_three, b_four = read(4, 'C*')
              twos_comp(b_one << 24 | b_two << 16 | b_three << 8 | b_four, 4)
          end
        end

        def twos_comp(num, byte_len)
          bit_len = byte_len * 8

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
    end
  end
end
