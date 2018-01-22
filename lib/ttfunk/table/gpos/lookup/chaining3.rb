module TTFunk
  class Table
    class Gpos
      module Lookup
        class Chaining3 < TTFunk::SubTable
          attr_reader :format, :backtrack_coverage_tables
          attr_reader :input_coverage_tables, :lookahead_coverage_tables

          private

          def parse!
            @format, backtrack_glyph_count = read(4, 'nn')
            @backtrack_coverage_tables = Sequence.from(io, backtrack_glyph_count, 'n') do |coverage_offset|
              # NOTE: Assume the coverage table offsets are relative to the
              # chaining3 lookup table. That's how it is for all other lookup
              # tables, but the documentation doesn't say so explicity.
              # https://www.microsoft.com/typography/otspec/gpos.htm#CCPF3
              CoverageTable.create(file, table_offset + coverage_offset)
            end

            input_glyph_count = read(2, 'n').first
            @input_coverage_tables = Sequence.from(io, input_glyph_count, 'n') do |coverage_offset|
              # See note above
              CoverageTable.create(file, table_offset + coverage_offset)
            end

            lookahead_glyph_count = read(2, 'n').first
            @lookahead_coverage_tables = Sequence.from(io, lookahead_glyph_count, 'n') do |coverage_offset|
              # See note above
              CoverageTable.create(file, table_offset + coverage_offset)
            end

            @length = 4 +
              backtrack_coverage_tables.length +
              input_coverage_tables.length +
              lookahead_coverage_tables.length
          end
        end
      end
    end
  end
end
