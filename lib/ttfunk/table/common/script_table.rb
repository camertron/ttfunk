module TTFunk
  class Table
    module Common
      class ScriptTable < TTFunk::SubTable
        attr_reader :tag, :default_lang_sys_offset, :lang_sys_tables

        def initialize(file, tag, offset)
          @tag = tag
          super(file, offset)
        end

        def default_lang_sys_table
          @default_lang_sys_table ||= if default_lang_sys_offset > 0
            LangSysTable.new(
              file, 'default', table_offset + default_lang_sys_offset
            )
          end
        end

        def encode
          EncodedString.create do |result|
            if default_lang_sys_table
              result << ph(:common, default_lang_sys_table.id, length: 2)
            else
              result.write(0, 'n')
            end

            result.write(lang_sys_tables.count, 'n')

            lang_sys_tables.encode_to(result) do |lang_sys_table|
              [lang_sys_table.tag, ph(:common, lang_sys_table.id, length: 2)]
            end

            lang_sys_tables.each do |lang_sys_table|
              result.resolve_placeholders(:common, lang_sys_table.id, [result.length].pack('n'))
              result << lang_sys_table.encode
            end

            if default_lang_sys_table
              result.resolve_placeholders(
                :common, default_lang_sys_table.id, [result.length].pack('n')
              )

              result << default_lang_sys_table.encode
            end
          end
        end

        def length
          @length + sum(lang_sys_tables, &:length)
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
