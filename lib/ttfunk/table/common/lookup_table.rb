module TTFunk
  class Table
    module Common
      class LookupTable < TTFunk::SubTable
        MARK_FILTERING_BIT_POS = 4

        attr_reader :sub_table_class_map
        attr_reader :lookup_type, :lookup_flag, :sub_tables, :mark_filtering_set

        def initialize(file, offset, sub_table_class_map)
          @sub_table_class_map = sub_table_class_map
          super(file, offset)
        end

        def encode
          EncodedString.create do |result|
            result.write([Gsub::Extension::LOOKUP_TYPE, lookup_flag.value, sub_tables.count], 'nnn')

            sub_tables.encode_to(result) do |sub_table|
              [ph(:common, sub_table.id, length: 2, relative_to: 0)]
            end

            result.write(mark_filtering_set, 'n') if mark_filtering_set
          end
        end

        def finalize(data)
          sub_tables.each do |sub_table|
            data.resolve_each(:common, sub_table.id) do |placeholder|
              [data.length - placeholder.relative_to].pack('n')
            end

            # just wrap everything in a freaking extension table so we don't have to
            # worry about super complicated overflow issues
            data << Gsub::Extension.encode(sub_table)
          end
        end

        def finalize_sub_tables(data)
          sub_tables.each do |sub_table|
            Gsub::Extension.finalize(sub_table, data)
          end
        end

        def length
          @length + sum(sub_tables, &:length)
        end

        private

        def parse!
          @lookup_type, lookup_flag_value, count = read(6, 'nnn')
          @lookup_flag = BitField.new(lookup_flag_value)

          @sub_tables = Sequence.from(io, count, 'n') do |sub_table_offset|
            sub_table_class_map[lookup_type].create(
              file, self, table_offset + sub_table_offset, lookup_type
            )
          end

          if lookup_flag.on?(MARK_FILTERING_BIT_POS)
            @mark_filtering_set = read(2, 'n').first
          end

          @length = 6 + sub_tables.length + (mark_filtering_set ? 2 : 0)
        end
      end
    end
  end
end
