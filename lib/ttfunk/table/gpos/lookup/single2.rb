module TTFunk
  class Table
    class Gpos
      module Lookup
        class Single2 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :value_format, :value_tables

          private

          def parse!
            @format, @coverage_offset, @value_format, count = read(8, 'nnnn')
            @value_tables = Gpos::ValueTable.create_sequence(io, count)
            @length = 8 + value_tables.length
          end
        end
      end
    end
  end
end
