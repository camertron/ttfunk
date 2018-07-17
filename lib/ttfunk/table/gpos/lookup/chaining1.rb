module TTFunk
  class Table
    class Gpos
      module Lookup
        class Chaining1 < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :chain_pos_rule_sets

          def max_context
            chain_pos_rule_sets.flat_map do |chain_pos_rule_set|
              chain_pos_rule_set.chain_pos_rules.map do |chain_pos_rule|
                chain_pos_rule.input_sequence.count +
                  chain_pos_rule.lookahead_glyph_ids.count
              end
            end.max
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format].pack('n')
              result << coverage_table.placeholder_relative_to(id)
              result << [chain_pos_rule_sets.count].pack('n')
              result << chain_pos_rule_sets.encode_to(result) do |chain_pos_rule_set|
                [chain_pos_rule_set.placeholder]
              end

              chain_pos_rule_sets.each do |chain_pos_rule_set|
                result.resolve_placeholder(
                  chain_pos_rule_set.id, [result.length].pack('n')
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
