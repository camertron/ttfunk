module TTFunk
  class Table
    module Common
      module Subst
        class Multiple < TTFunk::SubTable
          SEQUENCE_TABLE_OFFSET_LENGTH = 2

          attr_reader :format, :coverage_offset, :count

          def each
            return to_enum(__method__) unless block_given?
            count.times { |i| yield self[i] }
          end

          def [](index)
            sequence_offsets[index] ||= begin
              offset = index * SEQUENCE_TABLE_OFFSET_LENGTH

              sequence_offset_data = @raw_sequence_table_offset_array[
                offset, SEQUENCE_TABLE_OFFSET_LENGTH
              ]

              sequence_offset = sequence_offset_data.unpack('n').first
              SequenceTable.new(file, table_offset + sequence_offset)
            end
          end

          private

          def parse!
            @format, @coverage_offset, @count = read(6, 'n')

            @raw_sequence_table_offset_array = io.read(
              count * SEQUENCE_TABLE_OFFSET_LENGTH
            )

            @length = 6 + @raw_sequence_table_offset_array.length
          end

          def sequence_offsets
            @sequence_offsets ||= {}
          end
        end
      end
    end
  end
end
