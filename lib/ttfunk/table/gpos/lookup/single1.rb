module TTFunk
  class Table
    class Gpos
      module Lookup
        class Single1 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :value_format, :value_table

          private

          def parse!
            @format, @coverage_offset, @value_format = read(6, 'nnn')
            @value_table = ValueTable.new(file, io.pos)
            @length = 6 + value_table.length
          end
        end
      end
    end
  end
end
