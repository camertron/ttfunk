module TTFunk
  class Table
    class Gsub
      class Contextual2 < TTFunk::SubTable
        attr_reader :format, :coverage_offset, :class_def_offset, :sub_class_sets

        def coverage_table
          @coverage_table ||= Common::CoverageTable.create(
            file, self, table_offset + coverage_offset
          )
        end

        def class_def
          @class_def ||= Common::ClassDef.create(self, class_def_offset)
        end

        def max_context
          @max_context ||= sub_class_sets.flat_map do |sub_class_set|
            sub_class_set.sub_class_rules.map do |sub_class_rule|
              sub_class_rule.input_sequence.count
            end
          end.max
        end

        def encode
          EncodedString.create do |result|
            result.write(format, 'n')
            result << ph(:gsub, coverage_table.id, 2)
            result << ph(:gsub, class_def.id, 2)
            result.write(sub_class_sets.count, 'n')
            result << sub_class_sets.each do |sub_class_set|
              [ph(:gsub, sub_class_set.id, 2)]
            end

            sub_class_sets.each do |sub_class_set|
              result.resolve_placeholder(
                :gsub, sub_class_set.id, [result.length].pack('n')
              )

              result << sub_class_set.encode
            end
          end
        end

        private

        def parse!
          @format, @coverage_offset, @class_def_offset, count = read(8, 'n4')

          @sub_class_sets = Sequence.from(io, count, 'n') do |sub_class_set_offset|
            Common::SubClassSet.new(file, table_offset + sub_class_set_offset)
          end

          @length = 8 + sub_class_sets.length
        end
      end
    end
  end
end
