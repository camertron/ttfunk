module TTFunk
  class Table
    class Gsub
      module Lookup
        class Chaining3 < TTFunk::SubTable
          attr_reader :lookup_type
          attr_reader :format, :backtrack_coverage_tables, :input_coverage_tables
          attr_reader :lookahead_coverage_tables, :subst_lookup_tables

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

          def max_context
            input_coverage_tables.count + lookahead_coverage_tables.count
          end

          def dependent_coverage_tables
            backtrack_coverage_tables.to_a +
              input_coverage_tables.to_a +
              lookahead_coverage_tables.to_a
          end

          def encode
            EncodedString.new do |result|
              result << [format, backtrack_coverage_tables.count].pack('nn')

              backtrack_coverage_tables.encode_to(result) do |backtrack_coverage_table|
                [
                  Placeholder.new(
                    "gsub_#{backtrack_coverage_table.id}",
                    length: 2,
                    relative_to: 0
                  )
                ]
              end

              result << [input_coverage_tables.count].pack('n')

              input_coverage_tables.encode_to(result) do |input_coverage_table|
                [
                  Placeholder.new(
                    "gsub_#{input_coverage_table.id}",
                    length: 2,
                    relative_to: 0
                  )
                ]
              end

              result << [lookahead_coverage_tables.count].pack('n')

              lookahead_coverage_tables.encode_to(result) do |lookahead_coverage_table|
                [
                  Placeholder.new(
                    "gsub_#{lookahead_coverage_table.id}",
                    length: 2,
                    relative_to: 0
                  )
                ]
              end

              result << [subst_lookup_tables.count].pack('n')

              subst_lookup_tables.encode_to(result) do |subst_lookup_table|
                [
                  subst_lookup_table.glyph_sequence_index,
                  subst_lookup_table.lookup_list_index
                ]
              end
            end
          end

          def finalize(data)
            finalize_coverage_sequence(backtrack_coverage_tables, data)
            finalize_coverage_sequence(input_coverage_tables, data)
            finalize_coverage_sequence(lookahead_coverage_tables, data)
          end

          def length
            @length +
              sum(backtrack_coverage_tables, &:length) +
              sum(input_coverage_tables, &:length) +
              sum(lookahead_coverage_tables, &:length)
          end

          private

          # @TODO: Move to base class? Other things need this functionality.
          def finalize_coverage_sequence(coverage_sequence, data)
            coverage_sequence.each do |coverage_table|
              if data.placeholders.include?("gsub_#{coverage_table.id}")
                data.resolve_each("gsub_#{coverage_table.id}") do |placeholder|
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
            @subst_lookup_tables = Sequence.from(io, subst_count, Gsub::SubstLookupTable::FORMAT) do |*args|
              Gsub::SubstLookupTable.new(*args)
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
end
