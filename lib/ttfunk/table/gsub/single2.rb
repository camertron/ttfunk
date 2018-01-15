module TTFunk
  class Table
    class Gsub
      class Single2 < TTFunk::SubTable
        attr_reader :format, :coverage_offset, :glyph_ids

        def coverage_table
          @coverage_table ||= Common::CoverageTable.create(
            file, self, table_offset + coverage_offset
          )
        end

        def max_context
          1
        end

        def dependent_coverage_tables
          [coverage_table]
        end

        def encode
          EncodedString.create do |result|
            result.write(format, 'n')
            result << ph(:gsub, coverage_table.id, length: 2, relative_to: 0)
            result.write(glyph_ids.count, 'n')
            glyph_ids.encode_to(result)
          end
        end

        def finalize(data)
          if data.has_placeholders?(:gsub, coverage_table.id)
            data.resolve_each(:gsub, coverage_table.id) do |placeholder|
              [data.length - placeholder.relative_to].pack('n')
            end

            data << coverage_table.encode
          end
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
