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
          data[index] = get(index)
        end

        def each
          return to_enum(__method__) unless block_given?
          count.times { |i| yield self[i] }
        end

        def encode
          result = EncodedString.new

          entries = each_with_object([]) do |entry, ret|
            new_entry = block_given? ? yield(entry) : entry
            ret << new_entry if new_entry
          end

          # @TODO: is #round really the right answer here? Seems to work...
          offset_size = (Math.log2(entries.size) / 8.0).round + 1
          result << [entries.size, offset_size].pack('nc')
          data_offset = 1

          data = EncodedString.new

          entries.each_with_index do |entry, index|
            result << encode_offset(data_offset, offset_size)
            data << entry
            data_offset += entry.bytesize
          end

          if entries.size > 0
            result << encode_offset(data_offset, offset_size)
          end

          result << data
        end

        private

        def encode_offset(offset, offset_size)
          case offset_size
            when 1
              [offset].pack('C')
            when 2
              [offset].pack('n')
            when 3
              [offset].pack('N')[1..-1]
            when 4
              [offset].pack('N')
          end
        end

        private

        def get(index)
          if index >= count
            raise ArgumentError, "index of #{index} is out-of-bounds"
          end

          start, finish = relative_data_offsets_for(index)
          @raw_data_array[start...finish]
        end

        def parse!
          @count, @offset_size = read(3, 'nc')
          @raw_offset_array = io.read((count + 1) * offset_size)
          last_start, last_finish = relative_data_offsets_for(count - 1)
          @raw_data_array = io.read(last_finish)
          @length = 3 + @raw_offset_array.size + @raw_data_array.size
        end

        def relative_data_offsets_for(index)
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

        def absolute_data_offsets_for(index)
          start_offset, next_start_offset = relative_data_offsets_for(index)

          [
            table_offset + start_offset + @raw_offset_array.size + 3,
            table_offset + next_start_offset + @raw_offset_array.size + 3
          ]
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
