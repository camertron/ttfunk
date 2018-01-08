module TTFunk
  class Table
    module Common
      class ConditionSet < TTFunk::SubTable
        attr_reader :conditions

        def encode
          EncodedString.create do |result|
            result.write(conditions.count, 'n')
            result << conditions.encode do |condition|
              [ph(:common, condition.id, 2)]
            end

            conditions.each do |condition|
              result.resolve_placeholder(
                :common, condition.id, [result.length].encode('N')
              )

              result << condition.encode
            end
          end
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
