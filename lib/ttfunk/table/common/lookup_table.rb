module TTFunk
  class Table
    module Common
      class LookupTable < TTFunk::SubTable
        include Enumerable

        SUB_TABLE_OFFSET_LENGTH = 2

        attr_reader :lookup_type, :lookup_flag, :count
        attr_reader :mark_filtering_set

        def each
          return to_enum(__method__) unless block_given?
          count.times { |i| yield self[i] }
        end

        def [](index)
          indices[index] ||= begin
            offset_data = @raw_sub_table_offsets[
              index * SUB_TABLE_OFFSET_LENGTH, SUB_TABLE_OFFSET_LENGTH
            ]

            subtable_offset = offset_data.unpack('n').first

            case lookup_type
              when 1
                Subst::Single1.new(file, subtable_offset)
              when 2
                Subst::Single2.new(file, subtable_offset)
              # when... @TODO moar
            end
          end
        end

        private

        def parse!
          @lookup_type, @lookup_flag, @count = read(6, 'nnn')
          @raw_sub_table_offsets = io.read(count * SUB_TABLE_OFFSET_LENGTH)
          @mark_filtering_set = read(2, 'n')
          @length = 8 + @raw_sub_table_offsets.length
        end

        def indices
          @indices ||= []
        end
      end
    end
  end
end
