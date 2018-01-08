module TTFunk
  class Table
    class Gsub
      class Ligature < TTFunk::SubTable
        def self.create(file, _parent_table, offset)
          new(file, offset)
        end

        attr_reader :format, :coverage_offset, :ligature_sets

        def coverage_table
          @coverage_table ||= Common::CoverageTable.create(
            file, self, table_offset + coverage_offset
          )
        end

        def max_context
          @max_context ||= ligature_sets.flat_map do |ligature_set|
            ligature_set.tables.map do |ligature_table|
              ligature_table.component_glyph_ids.count
            end
          end.max
        end

        def encode
          EncodedString.create do |result|
            result.write(format, 'n')
            result << ph(:gsub, coverage_table.id, length: 2, relative_to: result.length)
            result << ligature_sets.encode do |ligature_set|
              [ph(:gsub, ligature_set.id, length: 2)]
            end

            ligature_sets.each do |ligature_set|
              result.resolve_placeholders(
                :gsub, ligature_set.id, [result.length].pack('n')
              )

              result << ligature_set.encode
            end
          end
        end

        private

        def parse!
          @format, @coverage_offset, count = read(6, 'nnn')

          @ligature_sets = Sequence.from(io, count, 'n') do |ligature_set_offset|
            Common::LigatureSet.new(file, table_offset + ligature_set_offset)
          end

          @length = 6 + ligature_sets.length
        end
      end
    end
  end
end
