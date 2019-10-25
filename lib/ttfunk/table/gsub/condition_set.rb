# frozen_string_literal: true

module TTFunk
  class Table
    class Gsub
      class ConditionSet < TTFunk::SubTable
        attr_reader :conditions

        def encode
          EncodedString.new do |result|
            result << [conditions.count].pack('n')
            conditions.encode_to(result) do |condition|
              [condition.placeholder]
            end

            conditions.each do |condition|
              result.resolve_placeholder(
                condition.id, [result.length].pack('N')
              )

              result << condition.encode
            end
          end
        end

        def length
          @length + sum(conditions, &:length)
        end

        private

        def parse!
          condition_count = read(2, 'n').first

          @conditions = Sequence.from(io, condition_count, 'N') do |ct_offset|
            ConditionTable.new(self, table_offset + ct_offset)
          end

          @length = 2 + conditions.length
        end
      end
    end
  end
end
