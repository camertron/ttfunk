module TTFunk
  class Table
    class Gsub
      class ReverseChaining < TTFunk::SubTable
        def self.create(file, _parent_table, offset)
          new(file, offset)
        end

        attr_reader :format, :coverage_offset, :backtrack_coverage_offsets
        attr_reader :lookahead_coverage_offsets, :substitute_glyph_ids

        def coverage_table
          @coverage_table ||= CoverageTable.create(
            file, self, table_offset + coverage_offset
          )
        end

        def max_context
          backtrack_coverage_offsets.count + lookahead_coverage_offsets.count
        end

        private

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
