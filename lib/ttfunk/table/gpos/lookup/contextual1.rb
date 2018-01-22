module TTFunk
  class Table
    class Gpos
      module Lookup
        class Contextual1 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :pos_rule_sets

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
