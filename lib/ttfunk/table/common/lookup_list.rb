module TTFunk
  class Table
    module Common
      class LookupList < TTFunk::SubTable
        attr_reader :lookup_table_class, :tables

        def initialize(file, offset, lookup_table_class)
          @lookup_table_class = lookup_table_class
          super(file, offset)
        end

        def encode(new2old_glyph, old2new_lookups)
          EncodedString.new do |result|
            result << [old2new_lookups.count].pack('n')
            old2new_lookups.each do |old_index, _|
              table = tables[old_index]
              result << Placeholder.new(table.id, length: 2)
            end

            old2new_lookups.each do |old_index, _|
              table = tables[old_index]
              result.resolve_placeholder(table.id, [result.length].pack('n'))
              result.tag_with(table.id)
              result << table.encode
            end
          end
        end

        def finalize(data, old2new_lookups)
          old2new_lookups.each do |old_index, _|
            old_total = $total
            old_len = data.length
            # binding.pry
            tables[old_index].finalize(data)
            diff = data.length - old_len
            $total += diff

            if format = tables[old_index].sub_tables.first.respond_to?(:format) ? tables[old_index].sub_tables.first.format : nil
              puts "#{tables[old_index].lookup_type}, #{format} => #{old_total}, #{$total}"
            else
              puts "#{tables[old_index].lookup_type} => #{old_total}, #{$total}"
            end
          end

          old2new_lookups.each do |old_index, _|
            tables[old_index].finalize_sub_tables(data)
          end
        end

        def length
          @length + sum(tables, &:length)
        end

        def old2new_lookups_for(glyph_ids)
          # return tables.to_a
          new_index = 0

          {}.tap do |old2new_lookups|
            tables.each_with_index do |table, old_index|
              exists = table.sub_tables.any? do |sub_table|
                        sub_table.dependent_coverage_tables.any? do |coverage_table|
                          !(coverage_table.glyph_ids & glyph_ids).empty?
                        end
                      end

              next unless exists
              old2new_lookups[old_index] = new_index
              new_index += 1
            end
          end
        end

        private

        def parse!
          count = read(2, 'n').first

          @tables = Sequence.from(io, count, 'n') do |lookup_table_offset|
            lookup_table_class.new(
              file,
              table_offset + lookup_table_offset,
              lookup_table_class
            )
          end

          @length = 2 + tables.length
        end
      end
    end
  end
end
