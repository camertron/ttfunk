module TTFunk
  class Table
    class Gsub
      module Lookup
        class Contextual2 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :lookup_type
          attr_reader :format, :coverage_offset, :class_def_offset
          attr_reader :sub_class_sets

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

          def class_def
            @class_def ||= Gsub::ClassDef.create(self, table_offset + class_def_offset)
          end

          def max_context
            @max_context ||= sub_class_sets.flat_map do |sub_class_set|
              sub_class_set.sub_class_rules.map do |sub_class_rule|
                sub_class_rule.input_sequence.count
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
              result << ph(:gsub, class_def.id, length: 2)
              result.write(sub_class_sets.count, 'n')
              sub_class_sets.encode_to(result) do |sub_class_set|
                if sub_class_set
                  [ph(:gsub, sub_class_set.id, length: 2)]
                else
                  [0]
                end
              end

              result.resolve_placeholders(
                :gsub, class_def.id, [result.length].pack('n')
              )

              result << class_def.encode

              sub_class_sets.each do |sub_class_set|
                next unless sub_class_set

                result.resolve_placeholders(
                  :gsub, sub_class_set.id, [result.length].pack('n')
                )

                result << sub_class_set.encode
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
            @length + sum(sub_class_sets) { |scs| scs&.length || 0 }
          end

          private

          def parse!
            @format, @coverage_offset, @class_def_offset, count = read(8, 'n4')

            @sub_class_sets = Sequence.from(io, count, 'n') do |sub_class_set_offset|
              if sub_class_set_offset > 0  # can be nil
                Gsub::SubClassSet.new(file, table_offset + sub_class_set_offset)
              end
            end

            @length = 8 + sub_class_sets.length
          end
        end
      end
    end
  end
end
