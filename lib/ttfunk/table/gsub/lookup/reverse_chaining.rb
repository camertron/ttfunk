module TTFunk
  class Table
    class Gsub
      module Lookup
        class ReverseChaining < TTFunk::SubTable
          include Common::CoverageTableMixin

          def self.create(file, _parent_table, offset, lookup_type)
            new(file, offset, lookup_type)
          end

          attr_reader :lookup_type
          attr_reader :format, :coverage_offset, :backtrack_coverage_offsets
          attr_reader :lookahead_coverage_offsets, :substitute_glyph_ids

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

          def max_context
            backtrack_coverage_offsets.count + lookahead_coverage_offsets.count
          end

          def dependent_coverage_tables
            [coverage_table] + backtrack_coverage_tables.to_a + lookahead_coverage_tables.to_a
          end

          def encode
            EncodedString.create do |result|
              result.write(format, 'n')
              result << ph(:gsub, coverage_table.id, length: 2, relative_to: 0)

              result << backtrack_coverage_tables.encode do |table|
                [ph(:gsub, table.id, length: 2, relative_to: result.length)]
              end

              result << lookahead_coverage_tables.encode do |table|
                [ph(:gsub, table.id, length: 2), relative_to: result.length]
              end

              reuslt << substitute_glyph_ids.encode
            end
          end

          def finalize(data)
            if data.has_placeholders?(:gsub, coverage_table.id)
              data.resolve_each(:gsub, coverage_table.id) do |placeholder|
                [data.length - placeholder.relative_to].pack('n')
              end

              data << coverage_table.encode
            end

            finalize_coverage_sequence(backtrack_coverage_tables, data)
            finalize_coverage_sequence(lookahead_coverage_tables, data)
          end

          private

          # @TODO: Move to base class? Other things need this functionality.
          def finalize_coverage_sequence(coverage_sequence, data)
            coverage_sequence.each do |coverage_table|
              if data.has_placeholders?(:gsub, coverage_table.id)
                data.resolve_each(:gsub, coverage_table.id) do |placeholder|
                  [data.length - placeholder.relative_to].pack('n')
                end

                data << coverage_table.encode
              end
            end
          end

          def parse!
            @format, @coverage_offset, backtrack_count = read(6, 'nnn')
            @backtrack_coverage_offsets = Sequence.from(io, backtrack_count, 'n')
            lookahead_count = read(2, 'n').first
            @lookahead_coverage_offsets = Sequence.from(io, lookahead_count, 'n')
            glyph_count = read(2, 'n').first
            @substitute_glyph_ids = Sequence.from(io, glyph_count, 'n')

            @length = 10 + backtrack_coverage_offsets.length +
              lookahead_coverage_offsets.length +
              substitute_glyph_ids.length
          end
        end
      end
    end
  end
end
