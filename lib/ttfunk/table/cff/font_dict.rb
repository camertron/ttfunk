module TTFunk
  class Table
    class Cff < TTFunk::Table
      class FontDict < TTFunk::Table::Cff::Dict
        PLACEHOLDER_LENGTH = 5
        PLACEHOLDER = ("\0" * PLACEHOLDER_LENGTH).freeze

        OPERATORS = {
          private: 18
        }

        OPERATOR_CODES = OPERATORS.invert

        attr_reader :top_dict

        def initialize(top_dict, file, offset, length = nil)
          super(file, offset, length)
          @top_dict = top_dict
        end

        def encode
          EncodedString.new.tap do |result|
            result << [length].pack('C')

            each_with_index do |(operator, operands), idx|
              if OPERATOR_CODES.include?(operator)
                result.add_placeholder(
                  :cff_font_dict, :"#{OPERATOR_CODES[operator]}_#{@table_offset}",
                  result.pos, PLACEHOLDER_LENGTH
                )

                result << PLACEHOLDER
              else
                operands.each { |operand| result << encode_operand(operand) }
              end

              result << encode_operator(operator)
            end
          end
        end

        def finalize(new_cff_data)
          encoded = encode_integer32(new_cff_data.length)
          new_cff_data.resolve_placeholder(:cff_font_dict, :"private_#{@table_offset}", encoded.pack('C*'))
          new_cff_data << private_dict.encode
        end

        def private_dict
          @private_dict ||=
            if info = self[OPERATORS[:private]]
              private_dict_length, private_dict_offset = info

              PrivateDict.new(
                file, top_dict.cff_offset + private_dict_offset, private_dict_length
              )
            end
        end
      end
    end
  end
end
