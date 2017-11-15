module TTFunk
  class Table
    class Cff < TTFunk::Table
      class Charset < TTFunk::Table::Cff::CffTable
        attr_reader :top_dict, :count

        def initialize(top_dict, file, offset, length = nil)
          @top_dict = top_dict
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
              # all glyphs in the font are covered. Use charstrings_index?
              @count = 0
              @entries = []
              @length = 0

              until @count >= top_dict.charstrings_index.count - 1
                @length += 2 + element_width
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
