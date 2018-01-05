module TTFunk
  class Table
    module Common
      module Subst
        class Multiple < TTFunk::SubTable
          SEQUENCE_TABLE_OFFSET_LENGTH = 2

          attr_reader :format, :coverage_offset, :sequences

          def self.create(file, offset)
            new(file, offset)
          end

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'n')
            sequence_table_offset_array = io.read(count * SEQUENCE_TABLE_OFFSET_LENGTH)

            @sequences = Sequence.new(sequence_table_offset_array, SEQUENCE_TABLE_OFFSET_LENGTH) do |sequence_offset_data|
              sequence_offset_data.unpack('n').first
            end

            @length = 6 + sequences.length
          end
        end
      end
    end
  end
end
