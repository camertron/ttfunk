module TTFunk
  class Table
    class Gpos
      module Lookup
        class Contextual3 < TTFunk::SubTable
          attr_reader :lookup_type
          attr_reader :format, :coverage_offsets, :pos_lookups

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

          def dependent_coverage_tables
            coverage_tables
          end

          def encode
            EncodedString.new do |result|
              result << [format, coverage_tables.count, pos_lookups.count].pack('nnn')

              result << coverage_tables.encode do |coverage_table|
                [Placeholder.new("gpos_#{coverage_table.id}", length: 2, relative_to: 0)]
              end

              result << pos_lookups.encode do |pos_lookup|
                [
                  pos_lookup.glyph_sequence_index,
                  pos_lookup.lookup_list_index
                ]
              end
            end
          end

          def finalize(data)
            finalize_coverage_sequence(coverage_tables, data)
          end

          private

          def finalize_coverage_sequence(coverage_sequence, data)
            coverage_sequence.each do |coverage_table|
              if data.placeholders.include?("gpos_#{coverage_table.id}")
                data.resolve_each("gpos_#{coverage_table.id}") do |placeholder|
                  [data.length - placeholder.relative_to].pack('n')
                end

                data << coverage_table.encode
              end
            end
          end

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
