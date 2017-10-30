module TTFunk
  class Table
    class Cff < TTFunk::Table
      class Index < TTFunk::Table::Cff::CffTable
        include Enumerable

        # number of objects in the index
        attr_reader :count

        # offset array element size
        attr_reader :offset_size

        def [](index)
          if index >= count
            raise ArgumentError, "index of #{index} is out-of-bounds"
          end

          data[index] ||= begin
            start, finish = data_offsets_for(index)
            @raw_data_array[start...finish]
          end
        end

        def each
          return to_enum(__method__) unless block_given?
          count.times { |i| yield self[i] }
        end

        private

        def parse!
          @count, @offset_size = read(3, 'nc')
          @raw_offset_array = io.read((count + 1) * offset_size)
          last_start, last_finish = data_offsets_for(count - 1)
          # binding.pry if self.class.name == 'TTFunk::Table::Cff::StringIndex'
          @raw_data_array = io.read(last_finish)
          @length = 3 + @raw_offset_array.size + @raw_data_array.size
        end

        def data_offsets_for(index)
          entry_start = index * offset_size
          next_entry_start = (index + 1) * offset_size

          start_offset = unpack_offset(
            @raw_offset_array[entry_start...(entry_start + offset_size)]
          )

          next_start_offset = unpack_offset(
            @raw_offset_array[next_entry_start...(next_entry_start + offset_size)]
          )

          [start_offset - 1, next_start_offset - 1]
        end

        def unpack_offset(offset_data)
          case offset_data.length
            when 1
              # 8-bit, 1 byte
              offset_data.unpack('C').first
            when 2
              # 16-bit, 2 bytes
              offset_data.unpack('n').first
            when 3
              # 24-bit, 3 bytes (left-pad w/extra byte)
              "\x00#{offset_data}".unpack('N').first
            when 4
              # 32-bit, 4 bytes
              offset_data.unpack('N').first
          end
        end

        def data
          @data ||= Array.new(count)
        end
      end
    end
  end
end
