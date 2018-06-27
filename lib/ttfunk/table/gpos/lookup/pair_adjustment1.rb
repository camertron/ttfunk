module TTFunk
  class Table
    class Gpos
      module Lookup
        class PairAdjustment1 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :lookup_type
          attr_reader :format, :coverage_offset, :value_format1, :value_format2
          attr_reader :pair_sets

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

          def dependent_coverage_tables
            [coverage_table]
          end

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << Placeholder.new("gpos_#{coverage_table.id}", length: 1, relative_to: 0)
              result << [value_format1, value_format2, pair_sets.count].pack('n*')
              pair_sets.encode_to(result) do |pair_set|
                [Placeholder.new("gpos_#{pair_set.id}", length: 2)]
              end

              pair_sets.each do |pair_set|
                result.resolve_placeholder("gpos_#{pair_set.id}", [result.length].pack('n'))
                result << pair_set.encode
              end
            end
          end

          def finalize(data)
            if data.placeholders.include?("gpos_#{coverage_table.id}")
              data.resolve_each("gpos_#{coverage_table.id}") do |placeholder|
                [data.length - placeholder.relative_to].pack('n')
              end

              data << coverage_table.encode
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
