module TTFunk
  class Table
    class Gpos
      module Lookup
        class PairAdjustment1 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :value_format1, :value_format2
          attr_reader :pair_sets

          private

          def parse!
            @format, @coverage_offset, @value_format1,
              @value_format2, count = read(10, 'n5')

            @pair_sets = Sequence.from(io, count, 'n') do |pair_set_offset|
              PairSet.new(file, table_offset + pair_set_offset)
            end

            @length = 10 + pair_sets.length
          end
        end
      end
    end
  end
end
