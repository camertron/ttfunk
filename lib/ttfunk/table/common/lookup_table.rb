module TTFunk
  class Table
    module Common
      class LookupTable < TTFunk::SubTable
        MARK_FILTERING_BIT_POS = 4

        attr_reader :lookup_table_class
        attr_reader :lookup_type, :lookup_flag, :sub_tables, :mark_filtering_set

        def initialize(file, offset, lookup_table_class)
          @lookup_table_class = lookup_table_class
          super(file, offset)
        end

        def encode
          EncodedString.new do |result|
            result.tag_with(id)
            result << [lookup_table_class::EXTENSION_LOOKUP_TYPE, lookup_flag.value, sub_tables.count].pack('nnn')

            sub_tables.encode_to(result) do |sub_table|
              [Placeholder.new(sub_table.id, length: 2, relative_to: id)]
            end

            result.write(mark_filtering_set, 'n') if mark_filtering_set
          end
        end

        def finalize(data)
          sub_tables.each do |sub_table|
            data.resolve_each(sub_table.id) do |placeholder|
              [data.length - data.tag_for(placeholder).position].pack('n')
            end

            # just wrap everything in a freaking extension table so we don't have to
            # worry about super complicated overflow issues
            data << lookup_table_class::EXTENSION_CLASS.encode(sub_table, self)
          end
        end

        def finalize_sub_tables(data)
          sub_tables.each do |sub_table|
            lookup_table_class::EXTENSION_CLASS.finalize(sub_table, data)
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
            lookup_table_class::SUB_TABLE_MAP[lookup_type].create(
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
