module TTFunk
  class Table
    class Cff < TTFunk::Table
      class TopDict < TTFunk::Table::Cff::Dict
        DEFAULT_CHARSTRING_TYPE = 2
        DEFAULT_CHARSET_ID = 0

        OPERATOR_MAP = {
          charset: 15,
          encoding: 16,
          charstrings: 17,
          private: 18,
          charstring_type: 1206,
          ros: 1230,
          fd_array: 1236,
          fd_select: 1237
        }

        attr_reader :cff

        def initialize(cff, *remaining_args)
          super(*remaining_args)
          @cff = cff
        end

        def ros
          self[OPERATOR_MAP[:ros]]
        end

        def ros?
          !!ros
        end

        def private_dict
          @private_dict ||= begin
            if info = self[OPERATOR_MAP[:private]]
              private_dict_length, private_dict_offset = info
              Dict.new(file, cff_offset + private_dict_offset, private_dict_length)
            end
          end
        end

        def encoding
          @encoding ||= begin
            # CID fonts don't specify an encoding, so this can be nil
            if encoding_offset = self[OPERATOR_MAP[:encoding]]
              Encoding.new(self, file, cff_offset + encoding_offset.first)
            end
          end
        end

        def charset
          @charset ||= begin
            if charset_offset_or_id = self[OPERATOR_MAP[:charset]]
              # Numbers from 0..2 mean charset IDs instead of offsets. IDs are basically
              # pre-defined sets of characters.
              #
              # In the case of an offset, add the CFF table's offset since the charset offset
              # is relative to the start of the CFF table.
              if charset_offset_or_id > 2
                charset_offset_or_id += cff_offset
              end

              Charset.new(self, file, charset_offset_or_id)
            else
              Charset.new(self, file, DEFAULT_CHARSET_ID)
            end
          end
        end

        def charstrings_index
          @charstrings_index ||= begin
            if charstrings_offset = self[OPERATOR_MAP[:charstrings]]
              CharstringsIndex.new(self, file, cff_offset + charstrings_offset.first)
            end
          end
        end

        def charstring_type
          @charstring_type = self[OPERATOR_MAP[:charstring_type]] || DEFAULT_CHARSTRING_TYPE
        end

        def font_index
          @font_index ||= begin
            if font_index_offset = self[OPERATOR_MAP[:fd_array]]
              FontIndex.new(self, file, cff_offset + font_index_offset.first)
            end
          end
        end

        def cff_offset
          cff.offset
        end
      end
    end
  end
end
