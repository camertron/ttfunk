module TTFunk
  class Table
    class Cff < TTFunk::Table
      class PrivateDict < TTFunk::Table::Cff::Dict
        DEFAULT_WIDTH_X_DEFAULT = 0
        DEFAULT_WIDTH_X_NOMINAL = 0

        PLACEHOLDER_LENGTH = 5
        PLACEHOLDER = ("\0" * PLACEHOLDER_LENGTH).freeze

        OPERATORS = {
          subrs: 19,
          default_width_x: 20,
          nominal_width_x: 21
        }

        OPERATOR_CODES = OPERATORS.invert

        def encode
          EncodedString.new.tap do |result|
            each_with_index do |(operator, operands), idx|
              case OPERATOR_CODES[operator]
                when :subrs
                  result << encode_subrs
                else
                  operands.each { |operand| result << encode_operand(operand) }
              end

              result << encode_operator(operator)
            end
          end
        end

        def finalize(new_cff_data)
          return unless subr_index
          encoded = encode_integer32(new_cff_data.length)
          new_cff_data.resolve_placeholder(
            :cff_private_dict, :"subrs_#{@table_offset}", encoded.pack('C*')
          )
          new_cff_data << subr_index.encode
        end

        def subr_index
          @subr_index ||=
            if subr_offset = self[OPERATORS[:subrs]]
              SubrIndex.new(file, table_offset + subr_offset.first)
            end
        end

        def default_width_x
          if width = self[OPERATORS[:default_width_x]]
            width.first
          else
            DEFAULT_WIDTH_X_DEFAULT
          end
        end

        def nominal_width_x
          if width = self[OPERATORS[:nominal_width_x]]
            width.first
          else
            DEFAULT_WIDTH_X_NOMINAL
          end
        end

        private

        def encode_subrs
          EncodedString.new.tap do |result|
            result.add_placeholder(
              :cff_private_dict, :"subrs_#{@table_offset}",
              result.pos, PLACEHOLDER_LENGTH
            )

            result << PLACEHOLDER
          end
        end
      end
    end
  end
end
