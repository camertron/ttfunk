module TTFunk
  class Table
    class Gpos
      module Lookup
        class Contextual2 < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :class_def_offset
          attr_reader :pos_class_sets

          def max_context
            pos_class_sets.flat_map do |pos_class_set|
              pos_class_set.pos_class_rules.map do |pos_class_rule|
                pos_class_rule.classes.count + 1
              end
            end.max
          end

          def class_def
            @class_def ||= Common::ClassDef.create(
              self, table_offset + class_def_offset
            )
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format].pack('n')
              result << coverage_table.placeholder_relative_to(id)
              result << class_def.id.placeholder
              result << [pos_class_sets.count].pack('n')
              pos_class_sets.encode_to(result) do |pos_class_set|
                next [0] unless pos_class_set
                [pos_class_set.placeholder]
              end

              result.resolve_placeholder(
                class_def.id, [result.length].pack('n')
              )

              result << class_def.encode

              pos_class_sets.each do |pos_class_set|
                next unless pos_class_set

                result.resolve_placeholder(
                  pos_class_set.id, [result.length].pack('n')
                )

                result << pos_class_set.encode
              end
            end
          end

          def length
            @length + sum(pos_class_sets) { |pcs| pcs&.length || 0 }
          end

          private

          def parse!
            @format, @coverage_offset, @class_def_offset, count = read(10, 'n5')

            @pos_class_sets = Sequence.from(io, count, 'n') do |pos_class_offset|
              PosClassSet.new(file, table_offset + pos_class_offset)
            end

            @length = 10 + pos_class_sets.length
          end
        end
      end
    end
  end
end
