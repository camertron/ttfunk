module TTFunk
  class Table
    module Common
      class ScriptTable < TTFunk::SubTable
        LANG_SYS_RECORD_LENGTH = 6

        attr_reader :tag, :default_lang_sys_offset, :lang_sys_tables

        def initialize(file, tag, offset)
          @tag = tag
          super(file, offset)
        end

        private

        def parse!
          @default_lang_sys_offset, count = read(4, 'nn')
          lang_sys_array = io.read(count * LANG_SYS_RECORD_LENGTH)

          @lang_sys_tables = Sequence.new(lang_sys_array, LANG_SYS_RECORD_LENGTH) do |lang_sys_data|
            tag, lang_sys_table_offset = lang_sys_data.unpack('A4n')
            LangSysTable.new(file, tag, table_offset + lang_sys_table_offset)
          end

          @length = 4 + lang_sys_tables.length
        end
      end
    end
  end
end
