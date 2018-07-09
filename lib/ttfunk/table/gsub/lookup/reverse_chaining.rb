module TTFunk
  class Table
    class Gsub
      module Lookup
        class ReverseChaining < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :backtrack_coverage_tables
          attr_reader :lookahead_coverage_tables, :substitute_glyph_ids

          def max_context
            backtrack_coverage_tables.count + lookahead_coverage_tables.count
          end

          def dependent_coverage_tables
            [coverage_table] +
              backtrack_coverage_tables.to_a +
              lookahead_coverage_tables.to_a
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format].pack('n')
              result << coverage_table.placeholder

              result << [backtrack_coverage_tables.count].pack('n')
              backtrack_coverage_tables.encode_to(result) do |cov_table|
                [cov_table.placeholder_relative_to(id)]
              end

              result << [lookahead_coverage_tables.count].pack('n')
              lookahead_coverage_tables.encode_to(result) do |cov_table|
                [cov_table.placeholder_relative_to(id)]
              end

              substitute_glyph_ids.encode_to(result)
            end
          end

          private

          def parse!
            @format, @coverage_offset, backtrack_count = read(6, 'nnn')
            @backtrack_coverage_tables = Sequence.from(io, backtrack_count, 'n') do |coverage_offset|
              Common::CoverageTable.create(file, self, table_offset + coverage_offset)
            end

            lookahead_count = read(2, 'n').first
            @lookahead_coverage_tables = Sequence.from(io, lookahead_count, 'n') do |coverage_offset|
              Common::CoverageTable.create(file, self, table_offset + coverage_offset)
            end

            glyph_count = read(2, 'n').first
            @substitute_glyph_ids = Sequence.from(io, glyph_count, 'n')

            @length = 10 + backtrack_coverage_tables.length +
              lookahead_coverage_tables.length +
              substitute_glyph_ids.length
          end
        end
      end
    end
  end
end
