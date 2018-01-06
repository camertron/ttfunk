module TTFunk
  class Table
    module Common
      module Subst
        class Contextual2 < TTFunk::SubTable
          attr_reader :format, :coverage_offset, :class_def_offset

          def coverage_table
            @coverage_table ||= CoverageTable.create(self, coverage_offset)
          end

          def class_def
            @class_def ||= ClassDef.create(self, class_def_offset)
          end

          private

          def parse!
            @format, @coverage_offset, @class_def_offset, count = read(8, 'n4')

            @sub_class_sets = Sequence.from(io, count, 'n') do |sub_class_set_offset|
              SubClassSet.new(file, table_offset + sub_class_set_offset)
            end

            @length = 8 + sub_class_sets.length
          end
        end
      end
    end
  end
end
