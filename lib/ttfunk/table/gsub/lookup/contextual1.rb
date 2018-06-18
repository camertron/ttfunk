module TTFunk
  class Table
    class Gsub
      module Lookup
        class Contextual1 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :lookup_type, :format, :coverage_offset, :sub_rule_sets

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

          def max_context
            @max_context ||= sub_rule_sets.flat_map do |sub_rule_set|
              sub_rule_set.sub_rules.map do |sub_rule|
                sub_rule.input_sequence.count
              end
            end.max
          end

          def dependent_coverage_tables
            [coverage_table]
          end

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << Placeholder.new("gsub_#{coverage_table.id}", length: 2, relative_to: 0)
              result << [sub_rule_sets.count].pack('n')
              result << sub_rule_sets.encode_to(result) do |sub_rule_set|
                [Placeholder.new("gsub_#{sub_rule_set.id}", length: 2)]
              end

              sub_rule_sets.each do |sub_rule_set|
                result.resolve_placeholder(
                  "gsub_#{sub_rule_set.id}", [result.length].pack('n')
                )

                result << sub_rule_set.encode
              end
            end
          end

          def finalize(data)
            if data.placeholders.include?("gsub_#{coverage_table.id}")
              data.resolve_each("gsub_#{coverage_table.id}") do |placeholder|
                [data.length - placeholder.relative_to].pack('n')
              end

              data << coverage_table.encode
            end
          end

          def length
            @length + sum(sub_rule_sets, &:length)
          end

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'nnn')

            @sub_rule_sets = Sequence.from(io, count, 'n') do |sub_rule_set_offset|
              Gsub::SubRuleSet.new(file, table_offset + sub_rule_set_offset)
            end

            @length = 6 + sub_rule_sets.length
          end
        end
      end
    end
  end
end
