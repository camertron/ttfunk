module TTFunk
  class Table
    module Common
      class ScriptTable < TTFunk::SubTable
        include Enumerable

        LANG_SYS_RECORD_LENGTH = 6

        attr_reader :tag, :default_lang_sys_offset, :count

        def initialize(file, tag, offset)
          @tag = tag
          super(file, offset)
        end

        def each
          return to_enum(__method__) unless block_given?
          count.times { |i| yield self[i] }
        end

        def [](index)
          list[index] ||= begin
            offset = index * LANG_SYS_RECORD_LENGTH
            tag, lang_sys_offset = @raw_record_array[offset, LANG_SYS_RECORD_LENGTH].unpack('A4n')
            LangSysTable.new(file, tag, table_offset + lang_sys_offset)
          end
        end

        private

        def parse!
          @default_lang_sys_offset, @count = read(4, 'nn')
          @raw_record_array = io.read(count * LANG_SYS_RECORD_LENGTH)
          @length = 4 + @raw_record_array.length
        end

        def list
          @list ||= {}
        end
      end
    end
  end
end
