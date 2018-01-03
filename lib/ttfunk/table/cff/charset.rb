module TTFunk
  class Table
    class Cff < TTFunk::Table
      class Charset < TTFunk::SubTable
        DEFAULT_CHARSET_ID = 0

        attr_reader :top_dict, :count, :offset_or_id

        def initialize(top_dict, file, offset_or_id = DEFAULT_CHARSET_ID, length = nil)
          @top_dict = top_dict
          @offset_or_id = offset_or_id
          super(file, offset, length)
        end

        def [](glyph_id)
          case format_sym
            when :array_format
              @entries[glyph_id]

            when :range_format_8, :range_format_16
              remaining = glyph_id

              @entries.each do |range|
                if range.size > remaining
                  return (range.first + remaining) - 1
                end

                remaining -= range.size
              end

              nil
          end
        end

        def offset
          # Numbers from 0..2 mean charset IDs instead of offsets. IDs are basically
          # pre-defined sets of characters.
          #
          # In the case of an offset, add the CFF table's offset since the charset offset
          # is relative to the start of the CFF table. Otherwise return nil (no offset).
          if offset_or_id > 2
            offset_or_id + top_dict.cff_offset
          end
        end

        def encode
          # no offset means no charset was specified (i.e. we're supposed to use the default one)
          # and there's nothing to encode
          return '' unless offset

          ''.tap do |result|
            result << [@format].pack('C')

            case format_sym
              when :array_format
                result << @entries.pack('n*')

              when :range_format_8, :range_format_16
                @entries.each do |range|
                  sid = range.first
                  num_left = range.last - range.first
                  result << [sid, num_left].pack(element_format)
                end
            end
          end
        end

        private

        def parse!
          @format = read(1, 'C').first

          case format_sym
            when :array_format
              @count = top_dict.charstrings_index.count
              @length = @count * element_width
              @entries = read(length, 'n*')

            when :range_format_8, :range_format_16
              # The number of ranges is not explicitly specified in the font.
              # Instead, software utilizing this data simply processes ranges until
              # all glyphs in the font are covered.
              @count = 0
              @entries = []
              @length = 0

              until @count >= top_dict.charstrings_index.count - 1
                @length += 1 + element_width
                sid, num_left = read(element_width, element_format)
                @entries << (sid..(sid + num_left))
                @count += num_left + 1
              end
          end
        end

        def element_width
          case format_sym
            when :array_format then 2  # SID
            when :range_format_8 then 3  # SID + Card8
            when :range_format_16 then 4  # SID + Card16
          end
        end

        def element_format
          case format_sym
            when :array_format then 'n'
            when :range_format_8 then 'nc'
            when :range_format_16 then 'nn'
          end
        end

        def format_sym
          case @format
            when 0 then :array_format
            when 1 then :range_format_8
            when 2 then :range_format_16
            else
              raise RuntimeError, "unsupported charset format '#{@format}'"
          end
        end
      end
    end
  end
end
