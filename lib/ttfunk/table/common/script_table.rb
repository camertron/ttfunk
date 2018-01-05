module TTFunk
  class Table
    module Common
      class ScriptTable < TTFunk::SubTable
        attr_reader :tag, :default_lang_sys_offset, :lang_sys_tables

        def initialize(file, tag, offset)
          @tag = tag
          super(file, offset)
        end

        private

        def parse!
          @default_lang_sys_offset, count = read(4, 'nn')

          @lang_sys_tables = Sequence.from(io, count, 'A4n') do |tag, lang_sys_table_offset|
            LangSysTable.new(file, tag, table_offset + lang_sys_table_offset)
          end

          @length = 4 + lang_sys_tables.length
        end
      end
    end
  end
end
