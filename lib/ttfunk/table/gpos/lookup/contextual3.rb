module TTFunk
  class Table
    class Gpos
      module Lookup
        class Contextual3 < TTFunk::SubTable
          attr_reader :format, :coverage_offsets, :pos_lookups

          private

          def parse!
            @format, glyph_count, pos_count = read(6, 'nnn')

            @coverage_offsets = Sequence.from(io, glyph_count, 'n') do |coverage_offset|
              CoverageTable.create(file, self, table_offset + coverage_offset)
            end

            @pos_lookups = PosLookupTable.create_sequence(io, pos_count)
            @length = 6 + coverage_offsets.length + pos_lookups.length
          end
        end
      end
    end
  end
end
