module TTFunk
  class Table
    class Gsub
      module Lookup
        class Chaining1 < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset
          attr_reader :chain_sub_rule_sets

          def max_context
            @max_context ||= chain_sub_rule_sets.flat_map do |chain_sub_rule_set|
              chain_sub_rule_set.chain_sub_rules.map do |chain_sub_rule|
                chain_sub_rule.input_glyph_ids.count + chain_sub_rule.lookahead_glyph_ids.count
              end
            end.max
          end

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << coverage_table.placeholder
              result << [chain_sub_rule_sets.count].pack('n')
              result << chain_sub_rule_sets.encode_to(result) do |chain_sub_rule_set|
                [chain_sub_rule_set.placeholder]
              end

              chain_sub_rule_sets.each do |chain_sub_rule_set|
                result.resolve_placeholder(
                  chain_sub_rule_set.id, [result.length].pack('n')
                )

                result << chain_sub_rule_set.encode
              end
            end
          end

          def finalize(data)
            if data.placeholders.include?(coverage_table.id)
              data.resolve_each(coverage_table.id) do |placeholder|
                [data.length - placeholder.relative_to].pack('n')
              end

              data << coverage_table.encode
            end
          end

          def length
            @length + sum(chain_sub_rule_sets, &:length)
          end

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'nnn')

            @chain_sub_rule_sets = Sequence.from(io, count, 'n') do |chain_sub_rule_set_offset|
              Gsub::ChainSubRuleSet.new(file, table_offset + chain_sub_rule_set_offset)
            end

            @length = 6 + chain_sub_rule_sets.length
          end
        end
      end
    end
  end
end
