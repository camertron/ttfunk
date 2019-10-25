# frozen_string_literal: true

module TTFunk
  class Table
    class Gsub
      module Lookup
        class ReverseChaining < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :substitute_glyph_ids

          # backtrack coverage tables, lookahead coverage tables
          attr_reader :bc_tables, :lac_tables

          def max_context
            bc_tables.count + lac_tables.count
          end

          def dependent_coverage_tables
            [coverage_table] +
              bc_tables.to_a +
              lac_tables.to_a
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format].pack('n')
              result << coverage_table.placeholder_relative_to(id)

              result << [bc_tables.count].pack('n')
              bc_tables.encode_to(result) do |cov_table|
                [cov_table.placeholder_relative_to(id)]
              end

              result << [lac_tables.count].pack('n')
              lac_tables.encode_to(result) do |cov_table|
                [cov_table.placeholder_relative_to(id)]
              end

              substitute_glyph_ids.encode_to(result)
            end
          end

          private

          def parse!
            # bc_count = backtrack count
            @format, @coverage_offset, bc_count = read(6, 'nnn')
            @bc_tables = Sequence.from(io, bc_count, 'n') do |cov_offset|
              Common::CoverageTable.create(
                file, self, table_offset + cov_offset
              )
            end

            lac_count = read(2, 'n').first
            @lac_tables = Sequence.from(io, lac_count, 'n') do |cov_offset|
              Common::CoverageTable.create(
                file, self, table_offset + cov_offset
              )
            end

            glyph_count = read(2, 'n').first
            @substitute_glyph_ids = Sequence.from(io, glyph_count, 'n')

            @length = 10 + bc_tables.length +
              lac_tables.length +
              substitute_glyph_ids.length
          end
        end
      end
    end
  end
end
