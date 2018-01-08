module TTFunk
  class Table
    class Gsub
      class Multiple < TTFunk::SubTable
        def self.create(file, _parent_table, offset)
          new(file, offset)
        end

        attr_reader :format, :coverage_offset, :sequences

        def coverage_table
          @coverage_table ||= Common::CoverageTable.create(
            file, self, table_offset + coverage_offset
          )
        end

        def encode
          EncodedString.create do |result|
            result.write(format, 'n')
            result << ph(:gsub, coverage_table.id, 2)
            result << sequences.encode do |sequence|
              [ph(:gsub, sequence.id, 2)]
            end

            sequences.each do |sequence|
              result.resolve_placeholder(
                :gsub, sequence.id, [result.length].pack('n')
              )

              result << sequence.encode
            end
          end
        end

        private

        def parse!
          @format, @coverage_offset, count = read(6, 'n')

          @sequences = Sequence.from(io, count, 'n') do |sequence_table_offset|
            Common::SequenceTable.new(file, table_offset + sequence_table_offset)
          end

          @length = 6 + sequences.length
        end
      end
    end
  end
end
