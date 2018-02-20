module TTFunk
  class Table
    class Cff < TTFunk::Table
      class Encoding < TTFunk::SubTable
        attr_reader :top_dict

        def initialize(top_dict, file, offset, length = nil)
          super(file, offset, length)
          @top_dict = top_dict
        end

        def [](index)
          case @format
            when 0
              @array[index]
            when 1
              remaining = index

              found_range = @array.find do |range|
                if range.size >= remaining
                  true
                else
                  remaining -= range.size
                  false
                end
              end

              found_range[remaining]
          end
        end

        def encode
          bytes = [].tap do |result|
            result << @format
            result << @count

            case @format
              when 0
                result += @array

              when 1
                @array.each do |range|
                  result << range.first
                  result << range.last - range.first
                end
            end
          end

          bytes.pack('C*')
        end

        private

        def parse!
          @format, @count = read(2, 'C*')
          @length = @count * element_length
          @array = parse_array(io.read(@length))
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
            when 0 then 1
            when 1 then 2
            else
              # @TODO: handle supplemental encoding (necessary?)
              raise RuntimeError, "'#{@format}' is an unsupported encoding format"
          end
        end
      end
    end
  end
end
