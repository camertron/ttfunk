module TTFunk
  class Table
    class Gsub
      class Single1 < TTFunk::SubTable
        attr_reader :format, :coverage_offset, :delta_glyph_id

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
          @format, @coverage_offset, @delta_glyph_id = read(6, 'nnn')
          @length = 6
        end
      end
    end
  end
end
