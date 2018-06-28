module TTFunk
  class Table
    class Gsub
      module Lookup
        class Multiple < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :sequences

          def max_context
            1
          end

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << coverage_table.placeholder
              result << [sequences.count].pack('n')
              result << sequences.encode_to(result) do |sequence|
                [sequence.placeholder]
              end

              sequences.each do |sequence|
                result.resolve_placeholder(
                  sequence.id, [result.length].pack('n')
                )

                result << sequence.encode
              end
            end
          end

          def length
            @length + sum(sequences, &:length)
          end

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'nnn')

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
