module TTFunk
  class Table
    class Gsub
      module Lookup
        class Extension < Base
          FORMAT = 1
          LOOKUP_TYPE = 7

          class << self
            def create(file, _parent_table, offset, lookup_type)
              new(file, offset, lookup_type).sub_table
            end

            def encode(sub_table, parent_table)
              EncodedString.new do |result|
                result << [FORMAT, sub_table.lookup_type].pack('nn')
                result << Placeholder.new(
                  sub_table.id, length: 4, relative_to: parent_table.id
                )
              end
            end

            def finalize(sub_table, data)
              data.resolve_each(sub_table.id) do |placeholder|
                [data.length - data.tag_for(placeholder).position].pack('N')
              end

              data << sub_table.encode
              sub_table.finalize(data)
            end
          end

          attr_reader :format, :extension_lookup_type, :extension_offset

          def sub_table
            @sub_table ||= Gsub::Lookup::LookupTable::SUB_TABLE_MAP[extension_lookup_type].create(
              file, self, table_offset + extension_offset, extension_lookup_type
            )
          end

          private

          def parse!
            @format, @extension_lookup_type, @extension_offset = read(8, 'nnN')
            @length = 8
          end
        end
      end
    end
  end
end
