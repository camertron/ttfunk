# frozen_string_literal: true

module TTFunk
  class Table
    class Gsub
      module Lookup
        class Contextual1 < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :sub_rule_sets

          def max_context
            @max_context ||= sub_rule_sets.flat_map do |sub_rule_set|
              sub_rule_set.sub_rules.map do |sub_rule|
                sub_rule.input_sequence.count
              end
            end.max
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format].pack('n')
              result << coverage_table.placeholder_relative_to(id)
              result << [sub_rule_sets.count].pack('n')
              result << sub_rule_sets.encode_to(result) do |sub_rule_set|
                [sub_rule_set.placeholder]
              end

              sub_rule_sets.each do |sub_rule_set|
                result.resolve_placeholder(
                  sub_rule_set.id, [result.length].pack('n')
                )

                result << sub_rule_set.encode
              end
            end
          end

          def length
            @length + sum(sub_rule_sets, &:length)
          end

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'nnn')

            @sub_rule_sets = Sequence.from(io, count, 'n') do |srs_offset|
              Gsub::SubRuleSet.new(file, table_offset + srs_offset)
            end

            @length = 6 + sub_rule_sets.length
          end
        end
      end
    end
  end
end
