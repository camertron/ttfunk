module TTFunk
  class Table
    class Gsub
      class Contextual1 < TTFunk::SubTable
        attr_reader :format, :coverage_offset, :sub_rule_sets

        def coverage_table
          @coverage_table ||= Common::CoverageTable.create(
            file, self, table_offset + coverage_offset
          )
        end

        def max_context
          @max_context ||= sub_rule_sets.flat_map do |sub_rule_set|
            sub_rule_set.sub_rules.map do |sub_rule|
              sub_rule.input_sequence.count
            end
          end.max
        end

        def encode
          EncodedString.create do |result|
            result.write(format, 'n')
            result << ph(:gsub, coverage_table.id, length: 2, relative_to: 0)
            result << sub_rule_sets.encode do |sub_rule_set|
              [ph(:gsub, sub_rule_set.id, length: 2)]
            end

            sub_rule_sets.each do |sub_rule_set|
              result.resolve_placeholders(
                :gsub, sub_rule_set.id, [result.length].pack('n')
              )

              result << sub_rule_set.encode
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

        private

        def parse!
          @format, @coverage_offset, count = read(6, 'nnn')

          @sub_rule_sets = Sequence.from(io, count, 'n') do |sub_rule_set_offset|
            Common::SubRuleSet.new(file, table_offset + sub_rule_set_offset)
          end

          @length = 6 + sub_rule_sets.length
        end
      end
    end
  end
end
