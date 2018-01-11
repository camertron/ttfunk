module TTFunk
  class Table
    class Gsub
      class Single1 < TTFunk::SubTable
        attr_reader :format, :coverage_offset, :delta_glyph_id

        def coverage_table
          @coverage_table ||= Common::CoverageTable.create(
            file, self, table_offset + coverage_offset
          )
        end

        def max_context
          1
        end

        def encode
          EncodedString.create do |result|
            result.write(format, 'n')
            result << ph(:gsub, coverage_table.id, length: 2, relative_to: 0)
            result.write(delta_glyph_id, 'n')
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
          @format, @coverage_offset, @delta_glyph_id = read(6, 'nnn')
          @length = 6
        end
      end
    end
  end
end
