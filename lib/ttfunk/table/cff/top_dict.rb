module TTFunk
  class Table
    class Cff < TTFunk::Table
      class TopDict < TTFunk::Table::Cff::Dict
        DEFAULT_CHARSTRING_TYPE = 2
        DEFAULT_CHARSET = 0

        OPERATOR_MAP = {
          charset: 15,
          encoding: 16,
          charstrings: 17,
          charstring_type: 1206,
          ros: 1230,
          fd_select: 1237
        }

        def ros
          self[OPERATOR_MAP[:ros]]
        end

        def ros?
          !!ros
        end

        def encoding
          @encoding ||= begin
            # CID fonts don't specify an encoding, so this can be nil
            if encoding_offset = self[OPERATOR_MAP[:encoding]]
              Encoding.new(self, file, encoding_offset)
            end
          end
        end

        def charset
          @charset ||= Charset.new(
            self, file, self[OPERATOR_MAP[:charset]] || DEFAULT_CHARSET
          )
        end

        def charstrings_index
          @charstrings_index ||= begin
            if charstrings_offset = self[OPERATOR_MAP[:charstrings]]
              Index.new(file, charstrings_offset)
            end
          end
        end

        def charstring_type
          @charstring_type = self[OPERATOR_MAP[:charstring_type]] || DEFAULT_CHARSTRING_TYPE
        end

        def font_index
          @font_index ||= begin
            if font_index_offset = self[OPERATOR_MAP[:fd_select]]
              FontIndex.new(file, font_index_offset.first)
            end
          end
        end
      end
    end
  end
end
