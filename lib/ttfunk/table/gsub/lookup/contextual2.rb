# frozen_string_literal: true

module TTFunk
  class Table
    class Gsub
      module Lookup
        class Contextual2 < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :class_def_offset
          attr_reader :sub_class_sets

          def class_def
            @class_def ||= Common::ClassDef.create(
              self, table_offset + class_def_offset
            )
          end

          def max_context
            @max_context ||= sub_class_sets.flat_map do |sub_class_set|
              sub_class_set.sub_class_rules.map do |sub_class_rule|
                sub_class_rule.input_sequence.count
              end
            end.max
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format].pack('n')
              result << coverage_table.placeholder_relative_to(id)
              result << class_def.placeholder
              result << [sub_class_sets.count].pack('n')
              sub_class_sets.encode_to(result) do |sub_class_set|
                next [0] unless sub_class_set

                [sub_class_set.placeholder]
              end

              result.resolve_placeholder(
                class_def.id, [result.length].pack('n')
              )

              result << class_def.encode

              sub_class_sets.each do |sub_class_set|
                next unless sub_class_set

                result.resolve_placeholder(
                  sub_class_set.id, [result.length].pack('n')
                )

                result << sub_class_set.encode
              end
            end
          end

          def length
            @length + sum(sub_class_sets) do |scs|
              scs ? scs.length : 0
            end
          end

          private

          def parse!
            @format, @coverage_offset, @class_def_offset, count = read(8, 'n4')

            @sub_class_sets = Sequence.from(io, count, 'n') do |sc_set_offset|
              if sc_set_offset > 0 # can be nil
                Gsub::SubClassSet.new(file, table_offset + sc_set_offset)
              end
            end

            @length = 8 + sub_class_sets.length
          end
        end
      end
    end
  end
end
