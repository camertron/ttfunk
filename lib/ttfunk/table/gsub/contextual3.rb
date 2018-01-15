module TTFunk
  class Table
    class Gsub
      class Contextual3 < TTFunk::SubTable
        attr_reader :coverage_tables, :subst_lookup_tables

        def max_context
          @coverage_tables.count
        end

        def dependent_coverage_tables
          coverage_tables
        end

        def encode
          EncodedString.create do |result|
            result.write([format, coverage_tables.count, subst_lookup_tables.count], 'nnn')

            result << coverage_tables.encode do |coverage_table|
              [ph(:gsub, coverage_table.id, length: 2, relative_to: 0)]
            end

            result << subst_lookup_tables.encode do |subst_lookup_table|
              [subst_lookup_table.glyph_sequence_index, subst_lookup_table.lookup_list_index]
            end
          end
        end

        def finalize(data)
          finalize_coverage_sequence(coverage_tables, data)
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
          @format, glyph_count, subst_count = read(6, 'nnn')

          @coverage_tables = Sequence.from(io, glyph_count, 'n') do |coverage_table_offset|
            Common::CoverageTable.create(file, self, table_offset + coverage_table_offset)
          end

          @subst_lookup_tables = Sequence.from(io, subst_count, Common::SubstLookupTable::FORMAT) do |*args|
            Common::SubstLookupTable.new(*args)
          end

          @length = 6 + coverage_tables.length + subst_lookup_tables.length
        end
      end
    end
  end
end
