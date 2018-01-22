module TTFunk
  class Table
    class Gsub
      module Lookup
        class Multiple < TTFunk::SubTable
          include Common::CoverageTableMixin

          def self.create(file, _parent_table, offset, lookup_type)
            new(file, offset, lookup_type)
          end

          attr_reader :lookup_type, :format, :coverage_offset, :sequences

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

          def dependent_coverage_tables
            [coverage_table]
          end

          def max_context
            1
          end

          def encode
            EncodedString.create do |result|
              result.write(format, 'n')
              result << ph(:gsub, coverage_table.id, length: 2, relative_to: 0)
              result << sequences.encode do |sequence|
                [ph(:gsub, sequence.id, length: 2)]
              end

              sequences.each do |sequence|
                result.resolve_placeholders(
                  :gsub, sequence.id, [result.length].pack('n')
                )

                result << sequence.encode
              end
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

          def length
            @length + sum(sequences, &:length)
          end

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'n')

            @sequences = Sequence.from(io, count, 'n') do |sequence_table_offset|
              Gsub::SequenceTable.new(file, table_offset + sequence_table_offset)
            end

            @length = 6 + sequences.length
          end
        end
      end
    end
  end
end
