module TTFunk
  class Table
    module Common
      class LookupList < TTFunk::SubTable
        attr_reader :lookup_table_class, :tables

        def initialize(file, offset, lookup_table_class)
          @lookup_table_class = lookup_table_class
          super(file, offset)
        end

        def encode
          # binding.pry
          EncodedString.create do |result|
            result.write(tables.count, 'n')
            # num_to_encode = 54
            # result.write(num_to_encode, 'n')
            # counter = 0
            tables.encode_to(result) do |table|
              # next if counter >= num_to_encode
              [ph(:common, table.id, length: 2)] #.tap { counter += 1 }
            end

            tables.each.with_index do |table, idx|
              # next if idx >= num_to_encode
              result.resolve_placeholders(:common, table.id, [result.length].pack('n'))
              result << table.encode
            end
          end
        end

        def finalize(data)
          # total_length = 0

          # tables.each do |table|
          #   needs_extension = false
          #   sub_table_length = 0

          #   table.sub_tables.each do |sub_table|
          #     data.placeholders_for(:common, sub_table.id).each do |placeholder|
          #       if (data.length - placeholder.relative_to) + total_length + sub_table_length >= (2 ** 16) - 1
          #         needs_extension = true
          #         break
          #       end
          #     end

          #     break if needs_extension
          #     sub_table_length += sub_table.length
          #   end

          #   if needs_extension
          #     total_length += 8
          #   else
          #     total_length += sub_table_length
          #   end

          #   puts needs_extension
          # end

          # # handle coverage table overflows
          # tables.each do |table|
          #   table.sub_tables.each do |sub_table|
          #   end
          # end

          tables.each { |table| table.finalize(data) }
          tables.each { |table| table.finalize_sub_tables(data) }
        end

        def length
          @length + sum(tables, &:length)
        end

        private

        def parse!
          count = read(2, 'n').first

          @tables = Sequence.from(io, count, 'n') do |lookup_table_offset|
            lookup_table_class.new(
              file,
              table_offset + lookup_table_offset,
              lookup_table_class::SUB_TABLE_MAP
            )
          end

          @length = 2 + tables.length
        end
      end
    end
  end
end
