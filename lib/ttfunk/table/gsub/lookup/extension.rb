module TTFunk
  class Table
    class Gsub
      module Lookup
        class Extension < TTFunk::SubTable
          FORMAT = 1
          LOOKUP_TYPE = 7

          class << self
            def create(file, _parent_table, offset, _lookup_type)
              new(file, offset).sub_table
            end

            def encode(sub_table)
              EncodedString.new do |result|
                result << [FORMAT, sub_table.lookup_type].pack('nn')
                result << Placeholder.new("gsub_#{sub_table.id}", length: 4, relative_to: 0)
              end
            end

            def finalize(sub_table, data)
              data.resolve_each("gsub_#{sub_table.id}") do |placeholder|
                [data.length - placeholder.relative_to].pack('N')
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
