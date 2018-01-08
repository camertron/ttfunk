module TTFunk
  class Table
    class Gsub
      class Chaining3 < TTFunk::SubTable
        attr_reader :format, :backtrack_coverage_tables, :input_coverage_tables
        attr_reader :lookahead_coverage_tables, :subst_lookup_tables

        def max_context
          input_coverage_tables.count + lookahead_coverage_tables.count
        end

        def encode
          EncodedString.create do |result|
            result.write([format, backtrack_coverage_tables.count], 'nn')

            result << backtrack_coverage_tables.encode do |backtrack_coverage_table|
              [ph(:gsub, backtrack_coverage_table.id, length: 2, relative_to: result.length)]
            end

            result.write(input_coverage_tables.count, 'n')

            result << input_coverage_tables.encode do |input_coverage_table|
              [ph(:gsub, input_coverage_table.id, length: 2, relative_to: result.length)]
            end

            result.write(lookahead_coverage_tables.count, 'n')

            result << lookahead_coverage_tables.encode do |lookahead_coverage_table|
              [ph(:gsub, lookahead_coverage_table.id, length: 2, relative_to: result.length)]
            end

            result.write(subst_lookup_tables.count, 'n')

            result << subst_lookup_tables.encode do |subst_lookup_table|
              [subst_lookup_table.glyph_sequence_index, subst_lookup_table.lookup_list_index]
            end
          end
        end

        def finalize(data)
          if data.has_placeholder?(:gsub, coverage_table.id)
            data.resolve_each(:gsub, coverage_table.id) do |placeholder|
              [data.length - placeholder.relative_to].pack('n')
            end

            data << coverage_table.encode
          end

          finalize_coverage_sequence(backtrack_coverage_tables)
          finalize_coverage_sequence(input_coverage_tables)
          finalize_coverage_sequence(lookahead_coverage_tables)
        end

        private

        # @TODO: Move to base class? Other things need this functionality.
        def finalize_coverage_sequence(coverage_sequence, data)
          coverage_sequence.each do |coverage_table|
            if data.has_placeholder?(:gsub, coverage_table.id)
              data.resolve_each(:gsub, coverage_table.id) do |placeholder|
                [data.length - placeholder.relative_to].pack('n')
              end

              data << coverage_table.encode
            end
          end
        end

        def parse!
          @format, backtrack_count = read(4, 'nn')
          @backtrack_coverage_tables = Sequence.from(io, backtrack_count, 'n') do |coverage_table_offset|
            Common::CoverageTable.create(file, self, table_offset + coverage_table_offset)
          end

          input_count = read(2, 'n').first
          @input_coverage_tables = Sequence.from(io, input_count, 'n') do |coverage_table_offset|
            Common::CoverageTable.create(file, self, table_offset + coverage_table_offset)
          end

          lookahead_count = read(2, 'n').first
          @lookahead_coverage_tables = Sequence.from(io, lookahead_count, 'n') do |coverage_table_offset|
            Common::CoverageTable.create(file, self, table_offset + coverage_table_offset)
          end

          subst_count = read(2, 'n').first
          @subst_lookup_tables = Sequence.from(io, subst_count, Common::SubstLookupTable::FORMAT) do |*args|
            Common::SubstLookupTable.new(*args)
          end

          @length = 10 + backtrack_coverage_tables.length +
            input_coverage_tables.length +
            lookahead_coverage_tables.length +
            subst_lookup_tables.length
        end
      end
    end
  end
end
