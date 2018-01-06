module TTFunk
  class Table
    module Common
      module Subst
        class Chaining3 < TTFunk::SubTable
          attr_reader :format, :backtrack_coverage_tables, :input_coverage_tables
          attr_reader :lookahead_coverage_tables, :subst_lookup_tables

          private

          def parse!
            @format, backtrack_count = read(4, 'nn')
            @backtrack_coverage_tables = Sequence.from(io, backtrack_count, 'n') do |coverage_table_offset|
              CoverageTable.new(file, table_offset + coverage_table_offset)
            end

            input_count = read(2, 'n').first
            @input_coverage_tables = Sequence.from(io, input_count, 'n') do |coverage_table_offset|
              CoverageTable.new(file, table_offset + coverage_table_offset)
            end

            lookahead_count = read(2, 'n').first
            @lookahead_coverage_tables = Sequence.from(io, input_count, 'n') do |coverage_table_offset|
              CoverageTable.new(file, table_offset + coverage_table_offset)
            end

            subst_count = read(2, 'n').first
            @subst_lookup_tables = Sequence.from(io, subst_count, SubstLookupTable::FORMAT) do |*args|
              SubstLookupTable.new(*args)
            end

            @length = 10 + backtrack_coverage_tables.length +
              input_coverage_tables.length +
              lookahead_coverage_tables.length +
              subst_lookup_tables.length
          end
        end
      end
    end
  end
end
