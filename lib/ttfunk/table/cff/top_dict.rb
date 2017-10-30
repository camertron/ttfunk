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
          charstring_type: 1206
        }

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
          @charstrings_index ||= CharstringsIndex.new(
            self, file, self[OPERATOR_MAP[:charstrings]]
          )
        end

        def charstring_type
          @charstring_type = self[OPERATOR_MAP[:charstring_type]] || DEFAULT_CHARSTRING_TYPE
        end
      end
    end
  end
end
