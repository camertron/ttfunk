module TTFunk
  class Table
    class Cff < TTFunk::Table
      class TopDict < TTFunk::Table::Cff::Dict
        DEFAULT_CHARSTRING_TYPE = 2
        POINTER_PLACEHOLDER_LENGTH = 5
        POINTER_PLACEHOLDER = ("\0" * POINTER_PLACEHOLDER_LENGTH).freeze
        PLACEHOLDER_LENGTH = 5
        PLACEHOLDER = ("\0" * PLACEHOLDER_LENGTH).freeze

        # operators whose values are offsets that point to other parts
        # of the file
        POINTER_OPERATORS = {
          charset: 15,
          encoding: 16,
          charstrings_index: 17,
          private: 18,
          font_index: 1236,
          font_dict_selector: 1237
        }

        # all the operators we currently care about
        OPERATORS = {
          **POINTER_OPERATORS,
          ros: 1230,
          charstring_type: 1206
        }

        OPERATOR_CODES = OPERATORS.invert

        attr_reader :cff

        def initialize(cff, *remaining_args)
          super(*remaining_args)
          @cff = cff
        end

        def encode
          EncodedString.new.tap do |result|
            each_with_index do |(operator, operands), idx|
              if operator == OPERATORS[:private]
                result << encode_private
              elsif pointer_operator?(operator)
                result.add_placeholder(
                  :cff_top_dict, OPERATOR_CODES[operator],
                  position: result.pos, length: POINTER_PLACEHOLDER_LENGTH
                )

                result << POINTER_PLACEHOLDER
              else
                operands.each { |operand| result << encode_operand(operand) }
              end

              result << encode_operator(operator)
            end
          end
        end

        def finalize(new_cff_data, mapping)
          finalize_subtable(new_cff_data, :charset, charset.encode) if charset
          finalize_subtable(new_cff_data, :encoding, encoding.encode) if encoding

          if charstrings_index
            finalize_subtable(
              new_cff_data, :charstrings_index, charstrings_index.encode(mapping) do |charstring|
                charstring.encode
              end
            )
          end

          if font_index
            finalize_subtable(
              new_cff_data, :font_index, font_index.encode { |font_dict| font_dict.encode }
            )

            font_index.finalize(new_cff_data)
          end

          if font_dict_selector
            finalize_subtable(new_cff_data, :font_dict_selector, font_dict_selector.encode)
          end

          encoded_private_dict = private_dict.encode
          encoded_offset = encode_integer32(new_cff_data.length)
          encoded_length = encode_integer32(encoded_private_dict.bytesize)

          new_cff_data.resolve_placeholders(
            :cff_top_dict, :"private_length_#{@table_offset}", encoded_length.pack('C*')
          )

          new_cff_data.resolve_placeholders(
            :cff_top_dict, :"private_offset_#{@table_offset}", encoded_offset.pack('C*')
          )

          private_dict.finalize(encoded_private_dict)
          new_cff_data << encoded_private_dict
        end

        def encode_private
          EncodedString.new.tap do |result|
            result.add_placeholder(
              :cff_top_dict, :"private_length_#{@table_offset}",
              position: result.pos, length: PLACEHOLDER_LENGTH
            )

            result << PLACEHOLDER

            result.add_placeholder(
              :cff_top_dict, :"private_offset_#{@table_offset}",
              position: result.pos, length: PLACEHOLDER_LENGTH
            )

            result << PLACEHOLDER
          end
        end

        def finalize_subtable(new_cff_data, name, table_data)
          encoded = encode_integer32(new_cff_data.length)
          new_cff_data.resolve_placeholders(:cff_top_dict, name, encoded.pack('C*'))
          new_cff_data << table_data
        end

        def pointer_operator?(operator)
          POINTER_OPERATORS.include?(OPERATOR_CODES[operator])
        end

        def ros
          self[OPERATORS[:ros]]
        end

        def ros?
          !!ros
        end

        def charset
          @charset ||=
            if charset_offset_or_id = self[OPERATORS[:charset]]
              if charset_offset_or_id.empty?
                Charset.new(self, file)
              else
                Charset.new(self, file, charset_offset_or_id.first)
              end
            end
        end

        def encoding
          @encoding ||= begin
            # PostScript type 1 fonts, i.e. CID fonts, i.e. some fonts that use
            # the CFF table, don't specify an encoding, so this can be nil
            if encoding_offset = self[OPERATORS[:encoding]]
              Encoding.new(self, file, cff_offset + encoding_offset.first)
            end
          end
        end

        # https://www.microsoft.com/typography/otspec/cff.htm
        #
        # "OpenType fonts with TrueType outlines use a glyph index to specify
        # and access glyphs within a font; e.g., to index within the 'loca' table
        # and thereby access glyph data in the 'glyf' table. This concept is
        # retained in OpenType CFF fonts, except that glyph data is accessed
        # through the CharStrings INDEX of the CFF table."
        def charstrings_index
          @charstrings_index ||=
            if charstrings_offset = self[OPERATORS[:charstrings_index]]
              CharstringsIndex.new(self, file, cff_offset + charstrings_offset.first)
            end
        end

        def charstring_type
          @charstring_type = self[OPERATORS[:charstring_type]] || DEFAULT_CHARSTRING_TYPE
        end

        def font_index
          @font_index ||=
            if font_index_offset = self[OPERATORS[:font_index]]
              FontIndex.new(self, file, cff_offset + font_index_offset.first)
            end
        end

        def font_dict_selector
          @font_dict_selector ||=
            if fd_select_offset = self[OPERATORS[:font_dict_selector]]
              FdSelector.new(self, file, cff_offset + fd_select_offset.first)
            end
        end

        def private_dict
          @private_dict ||=
            if info = self[OPERATORS[:private]]
              private_dict_length, private_dict_offset = info

              PrivateDict.new(
                file, cff_offset + private_dict_offset, private_dict_length
              )
            end
        end

        def cff_offset
          cff.offset
        end

        private

        def encode_charstring_type(charstring_type)
          if charstring_type == DEFAULT_CHARSTRING_TYPE
            ''
          else
            encode_operand(charstring_type)
          end
        end
      end
    end
  end
end
