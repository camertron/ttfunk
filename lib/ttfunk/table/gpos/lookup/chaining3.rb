module TTFunk
  class Table
    class Gpos
      module Lookup
        class Chaining3 < Base
          attr_reader :format, :backtrack_coverage_tables
          attr_reader :input_coverage_tables, :lookahead_coverage_tables

          def dependent_coverage_tables
            backtrack_coverage_tables.to_a +
              input_coverage_tables.to_a +
              lookahead_coverage_tables.to_a
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format, backtrack_coverage_tables.count].pack('nn')

              backtrack_coverage_tables.encode_to(result) do |backtrack_coverage_table|
                [backtrack_coverage_table.placeholder_relative_to(id)]
              end

              result << [input_coverage_tables.count].pack('n')

              input_coverage_tables.encode_to(result) do |input_coverage_table|
                [input_coverage_table.placeholder_relative_to(id)]
              end

              result << [lookahead_coverage_tables.count].pack('n')

              lookahead_coverage_tables.encode_to(result) do |lookahead_coverage_table|
                [lookahead_coverage_table.placeholder_relative_to(id)]
              end

              result << [subst_lookup_tables.count].pack('n')

              pos_lookup_tables.encode_to(result) do |pos_lookup_table|
                [
                  pos_lookup_table.sequence_index,
                  pos_lookup_table.lookup_list_index
                ]
              end
            end
          end

          def length
            @length +
              sum(backtrack_coverage_tables, &:length) +
              sum(input_coverage_tables, &:length) +
              sum(lookahead_coverage_tables, &:length)
          end

          private

          def parse!
            @format, backtrack_glyph_count = read(4, 'nn')
            @backtrack_coverage_tables = Sequence.from(io, backtrack_glyph_count, 'n') do |coverage_offset|
              # NOTE: Assume the coverage table offsets are relative to the
              # chaining3 lookup table. That's how it is for all other lookup
              # tables, but the documentation doesn't say so explicity.
              # https://www.microsoft.com/typography/otspec/gpos.htm#CCPF3
              Common::CoverageTable.create(file, self, table_offset + coverage_offset)
            end

            input_glyph_count = read(2, 'n').first
            @input_coverage_tables = Sequence.from(io, input_glyph_count, 'n') do |coverage_offset|
              # See note above
              Common::CoverageTable.create(file, self, table_offset + coverage_offset)
            end

            lookahead_glyph_count = read(2, 'n').first
            @lookahead_coverage_tables = Sequence.from(io, lookahead_glyph_count, 'n') do |coverage_offset|
              # See note above
              Common::CoverageTable.create(file, self, table_offset + coverage_offset)
            end

            pos_count = read(2, 'n').first
            @pos_lookup_tables = Sequence.from(io, subst_count, Gpos::PosLookupTable::FORMAT) do |*args|
              Gpos::PosLookupTable.new(*args)
            end

            @length = 4 +
              backtrack_coverage_tables.length +
              input_coverage_tables.length +
              lookahead_coverage_tables.length +
              pos_lookup_tables.length
          end
        end
      end
    end
  end
end
