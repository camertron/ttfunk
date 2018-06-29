module TTFunk
  class Table
    class Gpos
      module Lookup
        class Contextual1 < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :pos_rule_sets

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << coverage_table.placeholder
              result << [pos_rule_sets.count].pack('n')
              result << pos_rule_sets.encode_to(result) do |pos_rule_set|
                [pos_rule_set.placeholder]
              end

              pos_rule_sets.each do |pos_rule_set|
                result.resolve_placeholder(
                  pos_rule_set.id, [result.length].pack('n')
                )

                result << pos_rule_set.encode
              end
            end
          end

          def length
            @length + sum(pos_rule_sets, &:length)
          end

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'nnn')

            @pos_rule_sets = Sequence.from(io, count, 'n') do |pos_rule_set_offset|
              PosRuleSet.new(file, table_offset + pos_rule_set_offset)
            end

            @length = 6 + pos_rule_sets.length
          end
        end
      end
    end
  end
end
