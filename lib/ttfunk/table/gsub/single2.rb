module TTFunk
  class Table
    class Gsub
      class Single2 < TTFunk::SubTable
        attr_reader :format, :coverage_offset, :glyph_ids

        def coverage_table
          @coverage_table ||= CoverageTable.create(
            file, self, table_offset + coverage_offset
          )
        end

        def max_context
          1
        end

        private

        def parse!
          @format, @coverage_offset, count = read(6, 'nnn')
          @glyph_ids = Sequence.from(io, count, 'n')
          @length = 6 + glyph_ids.length
        end
      end
    end
  end
end
