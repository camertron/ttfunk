module TTFunk
  class Table
    class Gsub
      module Lookup
        class Alternate < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :alternate_sets

          def max_context
            1
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format].pack('n')
              result << coverage_table.placeholder_relative_to(id)
              result << [alternate_sets.count].pack('n')

              alternate_sets.encode_to(result) do |alternate_set|
                [alternate_set.placeholder]
              end

              alternate_sets.each do |alternate_set|
                result.resolve_placeholder(
                  alternate_set.id, [result.length].pack('n')
                )

                result << alternate_set.encode
              end
            end
          end

          def length
            @length + sum(alternate_sets, &:length)
          end

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'nnn')

            @alternate_sets = Sequence.from(io, count, 'n') do |alternate_set_offset|
              Gsub::AlternateSet.new(file, table_offset + alternate_set_offset)
            end

            @length = 6 + alternate_sets.length
          end
        end
      end
    end
  end
end
