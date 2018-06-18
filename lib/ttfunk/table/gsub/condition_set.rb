module TTFunk
  class Table
    class Gsub
      class ConditionSet < TTFunk::SubTable
        attr_reader :conditions

        def encode
          EncodedString.create do |result|
            result.write(conditions.count, 'n')
            conditions.encode_to(result) do |condition|
              [ph(:gsub, condition.id, length: 2)]
            end

            conditions.each do |condition|
              result.resolve_placeholders(
                :gsub, condition.id, [result.length].pack('N')
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

          @conditions = Sequence.from(io, count, 'N') do |condition_table_offset|
            ConditionTable.new(self, table_offset + condition_table_offset)
          end

          @length = 2 + conditions.length
        end
      end
    end
  end
end
