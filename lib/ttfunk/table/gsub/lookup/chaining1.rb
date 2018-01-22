module TTFunk
  class Table
    class Gsub
      module Lookup
        class Chaining1 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :lookup_type, :format, :coverage_offset, :chain_sub_rule_sets

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

          def max_context
            @max_context ||= chain_sub_rule_sets.flat_map do |chain_sub_rule_set|
              chain_sub_rule_set.chain_sub_rules.map do |chain_sub_rule|
                chain_sub_rule.input_glyph_ids.count + chain_sub_rule.lookahead_glyph_ids.count
              end
            end.max
          end

          def dependent_coverage_tables
            [coverage_table]
          end

          def encode
            EncodedString.create do |result|
              result.write(format, 'n')
              result << ph(:gsub, coverage_table.id, length: 2, relative_to: 0)
              result << chain_sub_rule_sets.encode do |chain_sub_rule_set|
                [ph(:gsub, chain_sub_rule_set.id, length: 2)]
              end

              chain_sub_rule_sets.each do |chain_sub_rule_set|
                result.resolve_placeholders(
                  :gsub, chain_sub_rule_set.id, [result.length].pack('n')
                )

                result << chain_sub_rule_set.encode
              end
            end
          end

          def finalize(data)
            if data.has_placeholders?(:gsub, coverage_table.id)
              data.resolve_each(:gsub, coverage_table.id) do |placeholder|
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
