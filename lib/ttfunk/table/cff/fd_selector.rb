module TTFunk
  class Table
    class Cff < TTFunk::Table
      class FdSelector < TTFunk::Table::Cff::CffTable
        RANGE_ENTRY_SIZE = 3

        attr_reader :top_dict, :count

        def initialize(top_dict, file, offset, length = nil)
          super(file, offset, length)
          @top_dict = top_dict
        end

        def [](glyph_id)
          case format_sym
            when :array_format
              entries[glyph_id]

            when :range_format
              entry = entries.bsearch do |range, _|
                if range.include?(glyph_id)
                  0
                elsif glyph_id < range.first
                  -1
                else
                  1
                end
              end

              entry.last  # fd index is last element
          end
        end

        private

        def parse!
          @format = read(1, 'C').first
          @length = 1

          case format_sym
            when :array_format
              @raw_data_array = io.read(n_glyphs)
              @length += @raw_data_array.bytesize
              @count = @raw_data_array.bytesize

            when :range_format
              @count = read(2, 'n').first
              @length += (@count * RANGE_ENTRY_SIZE) + 2  # +2 for sentinel GID
              @raw_data_array = io.read((@count * RANGE_ENTRY_SIZE) + 2)
          end
        end

        def entries
          @entries ||= case format_sym
            when :array_format
              @raw_data_array.bytes

            when :range_format
              Array.new(count) do |index|
                entry_start = index * RANGE_ENTRY_SIZE
                next_entry_start = (index + 1) * RANGE_ENTRY_SIZE

                range_start = @raw_data_array[entry_start, 2].unpack('n').first
                range_end = @raw_data_array[next_entry_start, 2].unpack('n').first
                fd_index = @raw_data_array[entry_start + 2].ord

                [(range_start...range_end), fd_index]
              end
          end
        end

        def n_glyphs
          top_dict.charstrings_index.count
        end

        def format_sym
          case @format
            when 0 then :array_format
            when 3 then :range_format
            else
              raise RuntimeError, "unsupported fd select format '#{@format}'"
          end
        end
      end
    end
  end
end
