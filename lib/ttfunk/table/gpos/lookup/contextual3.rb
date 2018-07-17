module TTFunk
  class Table
    class Gpos
      module Lookup
        class Contextual3 < Base
          attr_reader :format, :coverage_offsets, :pos_lookups

          def max_context
            # i.e. glyph count
            coverage_offsets.count
          end

          def dependent_coverage_tables
            coverage_tables
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format, coverage_tables.count, pos_lookups.count].pack('nnn')

              result << coverage_tables.encode do |coverage_table|
                [coverage_table.placeholder_relative_to(id)]
              end

              result << pos_lookups.encode do |pos_lookup|
                [
                  pos_lookup.glyph_sequence_index,
                  pos_lookup.lookup_list_index
                ]
              end
            end
          end

          private

          def parse!
            @format, glyph_count, pos_count = read(6, 'nnn')

            @coverage_offsets = Sequence.from(io, glyph_count, 'n') do |coverage_offset|
              CoverageTable.create(file, self, table_offset + coverage_offset)
            end

            @pos_lookups = Array.new(pos_count) do
              PosLookupTable.new(file, io.pos)
            end

            @length = 6 + coverage_offsets.length + sum(pos_lookups, &:length)
          end
        end
      end
    end
  end
end
