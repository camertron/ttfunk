module TTFunk
  class Table
    module Common
      module Subst
        class Ligature < TTFunk::SubTable
          def self.create(file, offset)
            new(file, offset)
          end

          attr_reader :format, :coverage_offset, :ligature_sets

          def coverage_table
            @coverage_table ||= CoverageTable.create(self, coverage_offset)
          end

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'nnn')

            @ligature_sets = Sequence.from(io, count, 'n') do |ligature_set_offset|
              LigatureSet.new(file, table_offset + ligature_set_offset)
            end

            @length = 6 + ligature_sets.length
          end
        end
      end
    end
  end
end
