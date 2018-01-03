module TTFunk
  class Table
    module Common
      class ScriptList < TTFunk::SubTable
        include Enumerable

        SCRIPT_RECORD_LENGTH = 6

        attr_reader :count

        def each
          return to_enum(__method__) unless block_given?
          count.times { |i| yield self[i] }
        end

        def [](index)
          script_tables[index] ||= begin
            offset = index * SCRIPT_RECORD_LENGTH
            tag, script_offset = @raw_script_tables_array[offset, SCRIPT_RECORD_LENGTH].unpack('A4n')
            ScriptTable.new(file, tag, table_offset + script_offset)
          end
        end

        private

        def parse!
          @count = read(2, 'n').first
          @raw_script_tables_array = io.read(count * SCRIPT_RECORD_LENGTH)
          @length = 2 + @raw_script_tables_array.length
        end

        def script_tables
          @script_tables ||= {}
        end
      end
    end
  end
end
