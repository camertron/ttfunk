module TTFunk
  class Table
    module Common
      module Subst
        class Contextual3 < TTFunk::SubTable
          attr_reader :coverage_tables, :subst_lookup_tables

          private

          def parse!
            @format, glyph_count, subst_count = read(6, 'nnn')

            @coverage_tables = Sequence.from(io, glyph_count, 'n') do |coverage_table_offset|
              CoverageTable.new(file, table_offset + coverage_table_offset)
            end

            @subst_lookup_tables = Sequence.from(io, subst_count, SubstLookupTable::FORMAT) do |*args|
              SubstLookupTable.new(*args)
            end

            @length = 6 + coverage_tables.length + subst_lookup_tables.length
          end
        end
      end
    end
  end
end
