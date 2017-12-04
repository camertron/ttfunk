module TTFunk
  class Table
    class Cff < TTFunk::Table
      class TopDict < TTFunk::Table::Cff::Dict
        DEFAULT_CHARSTRING_TYPE = 2
        DEFAULT_CHARSET_ID = 0

        NAMES_TO_OPERATORS = {
          charset: 15,
          encoding: 16,
          charstrings_index: 17,
          charstring_type: 1206,
          ros: 1230,
          font_index: 1236,
          font_dict_selector: 1237
        }

        attr_reader :cff

        def initialize(cff, *remaining_args)
          super(*remaining_args)
          @cff = cff
        end

        def ros
          self[NAMES_TO_OPERATORS[:ros]]
        end

        def ros?
          !!ros
        end

        def encoding
          @encoding ||= begin
            # CID fonts don't specify an encoding, so this can be nil
            if encoding_offset = self[NAMES_TO_OPERATORS[:encoding]]
              Encoding.new(self, file, cff_offset + encoding_offset.first)
            end
          end
        end

        def charset
          @charset ||= begin
            if charset_offset_or_id = self[NAMES_TO_OPERATORS[:charset]]
              if charset_offset_or_id.empty?
                Charset.new(self, file, DEFAULT_CHARSET_ID)
              else
                # Numbers from 0..2 mean charset IDs instead of offsets. IDs are basically
                # pre-defined sets of characters.
                #
                # In the case of an offset, add the CFF table's offset since the charset offset
                # is relative to the start of the CFF table.
                charset_offset_or_id = charset_offset_or_id.first

                if charset_offset_or_id > 2
                  charset_offset_or_id += cff_offset
                end

                Charset.new(self, file, charset_offset_or_id)
              end
            end
          end
        end

        def charstrings_index
          @charstrings_index ||= begin
            if charstrings_offset = self[NAMES_TO_OPERATORS[:charstrings_index]]
              CharstringsIndex.new(self, file, cff_offset + charstrings_offset.first)
            end
          end
        end

        def charstring_type
          @charstring_type = self[NAMES_TO_OPERATORS[:charstring_type]] || DEFAULT_CHARSTRING_TYPE
        end

        def font_index
          @font_index ||= begin
            if font_index_offset = self[NAMES_TO_OPERATORS[:font_index]]
              FontIndex.new(self, file, cff_offset + font_index_offset.first)
            end
          end
        end

        def font_dict_selector
          @font_dict_selector ||= begin
            if fd_select_offset = self[NAMES_TO_OPERATORS[:font_dict_selector]]
              FdSelector.new(self, file, cff_offset + fd_select_offset.first)
            end
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
