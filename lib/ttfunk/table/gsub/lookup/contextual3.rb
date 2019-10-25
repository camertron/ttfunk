# frozen_string_literal: true

module TTFunk
  class Table
    class Gsub
      module Lookup
        class Contextual3 < Base
          attr_reader :coverage_tables, :subst_lookup_tables

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

          def max_context
            @coverage_tables.count
          end

          def dependent_coverage_tables
            coverage_tables
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)

              header = [
                format, coverage_tables.count, subst_lookup_tables.count
              ]

              result << header.pack('nnn')

              result << coverage_tables.encode do |coverage_table|
                [coverage_table.placeholder_relative_to(id)]
              end

              result << subst_lookup_tables.encode do |subst_lookup_table|
                [
                  subst_lookup_table.glyph_sequence_index,
                  subst_lookup_table.lookup_list_index
                ]
              end
            end
          end

          private

          def parse!
            @format, glyph_cnt, subst_cnt = read(6, 'nnn')

            @coverage_tables = Sequence.from(io, glyph_cnt, 'n') do |ct_offset|
              Common::CoverageTable.create(
                file, self, table_offset + ct_offset
              )
            end

            fmt = Gsub::SubstLookupTable::FORMAT
            @subst_lookup_tables = Sequence.from(io, subst_cnt, fmt) do |*args|
              Gsub::SubstLookupTable.new(*args)
            end

            @length = 6 + coverage_tables.length + subst_lookup_tables.length
          end
        end
      end
    end
  end
end
