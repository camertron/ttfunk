# frozen_string_literal: true

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
              result.tag_with(id)
              result << [format].pack('n')
              result << coverage_table.placeholder_relative_to(id)
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

            @sequences = Sequence.from(io, count, 'n') do |st_offset|
              Gsub::SequenceTable.new(file, table_offset + st_offset)
            end

            @length = 6 + sequences.length
          end
        end
      end
    end
  end
end
