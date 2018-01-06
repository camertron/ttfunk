module TTFunk
  class Table
    module Common
      module Subst
        class Alternate < TTFunk::SubTable
          attr_reader :format, :coverage_offset, :alternate_sets

          def self.create(file, offset)
            new(file, offset)
          end

          def coverage_table
            @coverage_table ||= CoverageTable.create(self, coverage_offset)
          end

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'nnn')

            @alternate_sets = Sequence.new(io, count, 'n') do |alternate_set_offset|
              AlternateSet.new(file, table_offset + alternate_set_offset)
            end

            @length = 6 + alternate_sets.length
          end
        end
      end
    end
  end
end
