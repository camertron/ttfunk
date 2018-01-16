module TTFunk
  class Table
    class Gsub
      class Extension < TTFunk::SubTable
        FORMAT = 1
        LOOKUP_TYPE = 7

        class << self
          def create(file, _parent_table, offset, _lookup_type)
            new(file, offset).sub_table
          end

          def encode(sub_table)
            EncodedString.create do |result|
              result.write([FORMAT, sub_table.lookup_type], 'nn')
              result << Placeholder.new(:common, sub_table.id, length: 4, relative_to: 0)
              # result.write(result.length + 4, 'N')  # no need for a placeholder here
            end
          end

          def finalize(sub_table, data)
            data.resolve_each(:common, sub_table.id) do |placeholder|
              [data.length - placeholder.relative_to].pack('N')
            end

            data << sub_table.encode
            sub_table.finalize(data)
          end
        end

        attr_reader :format, :extension_lookup_type, :extension_offset

        def sub_table
          @sub_table ||= Gsub::LookupTable::SUB_TABLE_MAP[extension_lookup_type].create(
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
