module TTFunk
  class Table
    class Gpos
      module Lookup
        class Chaining1 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :chain_pos_rule_sets

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << Placeholder.new("gsub_#{coverage_table.id}", length: 2, relative_to: 0)
              result << [count].pack('n')
              result << chain_pos_rule_sets.encode_to(result) do |chain_pos_rule_set|
                [Placeholder.new("gsub_#{chain_pos_rule_set.id}", length: 2)]
              end

              chain_pos_rule_sets.each do |chain_pos_rule_set|
                result.resolve_placeholder(
                  "gsub_#{chain_pos_rule_set.id}", [result.length].pack('n')
                )

                result << chain_pos_rule_set.encode
              end
            end
          end

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'nnn')

            @chain_pos_rule_sets = Sequence.from(io, count, 'n') do |chain_pos_rule_set_offset|
              ChainPosRuleSet.new(file, table_offset + chain_pos_rule_set_offset)
            end

            @length = 6 + chain_pos_rule_sets.length
          end
        end
      end
    end
  end
end
