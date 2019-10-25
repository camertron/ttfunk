# frozen_string_literal: true

module TTFunk
  class Table
    class Gsub
      module Lookup
        class Chaining1 < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset
          attr_reader :chain_sub_rule_sets

          def max_context
            @max_context ||= chain_sub_rule_sets.flat_map do |cs_rule_set|
              cs_rule_set.chain_sub_rules.map do |cs_rule|
                cs_rule.input_glyph_ids.count +
                  cs_rule.lookahead_glyph_ids.count
              end
            end.max
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format].pack('n')
              result << coverage_table.placeholder_relative_to(id)
              result << [chain_sub_rule_sets.count].pack('n')
              result << chain_sub_rule_sets.encode_to(result) do |cs_rule_set|
                [cs_rule_set.placeholder]
              end

              chain_sub_rule_sets.each do |cs_rule_set|
                result.resolve_placeholder(
                  cs_rule_set.id, [result.length].pack('n')
                )

                result << cs_rule_set.encode
              end
            end
          end

          def length
            @length + sum(chain_sub_rule_sets, &:length)
          end

          private

          def parse!
            @format, @coverage_offset, cnt = read(6, 'nnn')

            @chain_sub_rule_sets = Sequence.from(io, cnt, 'n') do |csrs_offset|
              Gsub::ChainSubRuleSet.new(file, table_offset + csrs_offset)
            end

            @length = 6 + chain_sub_rule_sets.length
          end
        end
      end
    end
  end
end
