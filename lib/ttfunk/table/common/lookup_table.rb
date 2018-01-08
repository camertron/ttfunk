module TTFunk
  class Table
    module Common
      class LookupTable < TTFunk::SubTable
        attr_reader :sub_table_class_map
        attr_reader :lookup_type, :lookup_flag, :sub_tables, :mark_filtering_set

        def initialize(file, offset, sub_table_class_map)
          @sub_table_class_map = sub_table_class_map
          super(file, offset)
        end

        def encode
          EncodedString.create do |result|
            result.write([lookup_type, lookup_flag, sub_tables.count], 'nnn')

            result << sub_tables.encode do |sub_table|
              [ph(:common, sub_table.id, 2)]
            end

            result.write(mark_filtering_set, 'n')

            sub_tables.each do |sub_table|
              result.resolve_placeholder(:common, sub_table.id, [result.length].pack('n'))
              result << sub_table.encode
            end
          end
        end

        private

        def parse!
          @lookup_type, @lookup_flag, count = read(6, 'nnn')

          @sub_tables = Sequence.from(io, count, 'n') do |sub_table_offset|
            sub_table_class_map[lookup_type].create(
              file, self, table_offset + sub_table_offset
            )
          end

          @mark_filtering_set = read(2, 'n')
          @length = 8 + sub_tables.length
        end
      end
    end
  end
end
