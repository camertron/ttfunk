module TTFunk
  class Table
    class Gpos
      class PairSet < TTFunk::SubTable
        attr_reader :pair_value_tables

        private

        def parse!
          count = read(2, 'n').first
          @pair_value_tables = Sequence.from(io, count, 'n') do |pair_value_table_offset|
            PairValueTable.new(file, table_offset + pair_value_table_offset)
          end
        end
      end
    end
  end
end
