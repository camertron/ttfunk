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

        private

        def parse!
          @dict = {}
          operands = []
          operator = nil

          @length = read(1, 'C').first - 1

          while io.pos <= table_offset + length
            case b_zero = read(1, 'C').first
              when 12
                operator = get_two_byte_operator
                @dict[operator] = operands
                operands = []
              when 0..21
                @dict[b_zero] = operands
                operands = []
              when 28..30, 32..254
                operands << get_operand(b_zero)
              else
                raise RuntimeError, "dict byte value #{b_zero} is reserved"
            end
          end
        end

        def get_two_byte_operator
          1200 + read(1, 'C').first
        end

        def get_operator
          read(1, 'C').first
        end

        def get_operand(b_zero)
          case b_zero
            when 30
              get_real
            else
              get_integer(b_zero)
          end
        end

        def get_real
          mantissa = ''
          exponent = ''

          loop do
            current = read(1, 'C').first
            break if current == 0xFF

            high_nibble = current >> 4
            low_nibble = current & 0b00001111

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

          mantissa.to_f * (10 ** exponent.to_i)
        end

        def get_integer(b_zero)
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
