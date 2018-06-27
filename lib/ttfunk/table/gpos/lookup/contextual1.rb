module TTFunk
  class Table
    class Gpos
      module Lookup
        class Contextual1 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :pos_rule_sets

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

          def dependent_coverage_tables
            [coverage_table]
          end

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << Placeholder.new("gpos_#{coverage_table.id}", length: 2, relative_to: 0)
              result << [pos_rule_sets.count].pack('n')
              result << pos_rule_sets.encode_to(result) do |pos_rule_set|
                [Placeholder.new("gpos_#{pos_rule_set.id}", length: 2)]
              end

              pos_rule_sets.each do |pos_rule_set|
                result.resolve_placeholder(
                  "gpos_#{pos_rule_set.id}", [result.length].pack('n')
                )

                result << pos_rule_set.encode
              end
            end
          end

          def finalize(data)
            if data.placeholders.include?("gpos_#{coverage_table.id}")
              data.resolve_each("gpos_#{coverage_table.id}") do |placeholder|
                [data.length - placeholder.relative_to].pack('n')
              end

              data << coverage_table.encode
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
