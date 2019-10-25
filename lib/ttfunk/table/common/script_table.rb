# frozen_string_literal: true

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
          @default_lang_sys_table ||=
            if default_lang_sys_offset > 0
              LangSysTable.new(
                file, 'default', table_offset + default_lang_sys_offset
              )
            end
        end

        def encode(old_to_new_features)
          EncodedString.new do |result|
            include_default = include_lang_sys_table?(
              default_lang_sys_table, old_to_new_features
            )

            result << if default_lang_sys_table && include_default
                        default_lang_sys_table.placeholder
                      else
                        result << [0].pack('n')
                      end

            ls_tables = lang_sys_tables_for(old_to_new_features)
            result << [ls_tables.count].pack('n')

            ls_tables.each do |ls_table|
              result << [ls_table.tag].pack('A4')
              result << ls_table.placeholder
            end

            ls_tables.each do |ls_table|
              result.resolve_each(ls_table.id) do |_placeholder|
                [result.length].pack('n')
              end

              result << ls_table.encode(old_to_new_features)
            end

            if default_lang_sys_table && include_default
              result.resolve_placeholder(
                default_lang_sys_table.id, [result.length].pack('n')
              )

              result << default_lang_sys_table.encode(old_to_new_features)
            end
          end
        end

        def length
          @length + sum(lang_sys_tables, &:length)
        end

        private

        def lang_sys_tables_for(old_to_new_features)
          lang_sys_tables.select do |table|
            include_lang_sys_table?(table, old_to_new_features)
          end
        end

        def include_lang_sys_table?(table, old_to_new_features)
          if table.includes_required_feature?
            unless old_to_new_features.include?(table.required_feature_index)
              return false
            end
          end

          table.feature_indices.all? do |index|
            old_to_new_features.include?(index)
          end
        end

        def parse!
          @default_lang_sys_offset, count = read(4, 'nn')

          # lst_off = lang sys table offset
          @lang_sys_tables = Sequence.from(io, count, 'A4n') do |tag, lst_off|
            LangSysTable.new(file, tag, table_offset + lst_off)
          end

          @length = 4 + lang_sys_tables.length
        end
      end
    end
  end
end
