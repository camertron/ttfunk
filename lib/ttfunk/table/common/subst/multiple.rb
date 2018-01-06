module TTFunk
  class Table
    module Common
      module Subst
        class Multiple < TTFunk::SubTable
          def self.create(file, offset)
            new(file, offset)
          end

          attr_reader :format, :coverage_offset, :sequences

          def coverage_table
            @coverage_table ||= CoverageTable.create(self, coverage_offset)
          end

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'n')

            @sequences = Sequence.from(io, count, 'n') do |sequence_table_offset|
              SequenceTable.new(file, table_offset + sequence_table_offset)
            end

            @length = 6 + sequences.length
          end
        end
      end
    end
  end
end
