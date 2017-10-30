module TTFunk
  class Table
    class Cff < TTFunk::Table
      class Charset < TTFunk::Table::Cff::CffTable
        attr_reader :top_dict

        def initialize(top_dict, file, offset, length = nil)
          super(file, offset, length)
          @top_dict = top_dict
        end

        private

        def parse!
          @format = read(1, 'C').first

          case @format
            when 0
              @count = top_dict.charstrings_index.count
              @length = @count * element_length
            when 1
              # The number of ranges is not explicitly specified in the font.
              # Instead, software utilizing this data simply processes ranges until
              # all glyphs in the font are covered. Use charstrings_index?
            when 2
              # See `when 1` above
            else
              raise RuntimeError, "'#{@format}' is an unsupported encoding format"
          end
        end

        def parse_array(data)
          case @format
            when 0
              data.bytes
            when 1
              data.bytes.each_slice(2).map do |first, num_left|
                first..(first + num_left)
              end
            else
              raise RuntimeError, "'#{@format}' is an unsupported encoding format"
          end
        end

        def element_length
          case @format
            when 0 then 2  # SID
            when 1 then 3  # SID + Card8
            when 2 then 4  # SID + Card16
            else
              # @TODO: handle supplemental encoding
              raise RuntimeError, "'#{@format}' is an unsupported encoding format"
          end
        end
      end
    end
  end
end
