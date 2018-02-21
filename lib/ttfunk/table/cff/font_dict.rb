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
            each_with_index do |(operator, operands), idx|
              case OPERATOR_CODES[operator]
                when :private
                  result << encode_private
                else
                  operands.each { |operand| result << encode_operand(operand) }
              end

              result << encode_operator(operator)
            end
          end
        end

        def finalize(new_cff_data)
          encoded_private_dict = private_dict.encode
          encoded_offset = encode_integer32(new_cff_data.length)
          encoded_length = encode_integer32(encoded_private_dict.bytesize)

          new_cff_data.resolve_placeholders(
            :cff_font_dict, :"private_length_#{@table_offset}", encoded_length.pack('C*')
          )

          new_cff_data.resolve_placeholders(
            :cff_font_dict, :"private_offset_#{@table_offset}", encoded_offset.pack('C*')
          )

          private_dict.finalize(encoded_private_dict)
          new_cff_data << encoded_private_dict
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

        private

        def encode_private
          EncodedString.new.tap do |result|
            result.add_placeholder(
              :cff_font_dict, :"private_length_#{@table_offset}",
              position: result.pos, length: PLACEHOLDER_LENGTH
            )

            result << PLACEHOLDER

            result.add_placeholder(
              :cff_font_dict, :"private_offset_#{@table_offset}",
              position: result.pos, length: PLACEHOLDER_LENGTH
            )

            result << PLACEHOLDER
          end
        end
      end
    end
  end
end
