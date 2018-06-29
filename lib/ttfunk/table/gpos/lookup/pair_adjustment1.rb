module TTFunk
  class Table
    class Gpos
      module Lookup
        class PairAdjustment1 < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :value_format1, :value_format2
          attr_reader :pair_sets

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << coverage_table.placeholder
              result << [value_format1, value_format2, pair_sets.count].pack('n*')
              pair_sets.encode_to(result) do |pair_set|
                [pair_set.placeholder]
              end

              pair_sets.each do |pair_set|
                result.resolve_placeholder(pair_set.id, [result.length].pack('n'))
                result << pair_set.encode
              end
            end
          end

          private

          def parse!
            @format, @coverage_offset, @value_format1,
              @value_format2, count = read(10, 'n5')

            @pair_sets = Sequence.from(io, count, 'n') do |pair_set_offset|
              PairSet.new(
                file,
                table_offset + pair_set_offset,
                value_format1,
                value_format2,
                table_offset
              )
            end

            @length = 10 + pair_sets.length
          end
        end
      end
    end
  end
end
