module TTFunk
  class Table
    class Gsub
      module Lookup
        class Chaining2 < TTFunk::SubTable
          attr_reader :lookup_type
          attr_reader :format, :coverage_offset, :backtrack_class_def_offset
          attr_reader :input_class_def_offset, :lookahead_class_def_offset
          attr_reader :chain_sub_class_sets

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

          def coverage_table
            @coverage_table ||= Common::CoverageTable.create(
              file, self, table_offset + coverage_offset
            )
          end

          def backtrack_class_def
            @backtrack_class_def ||= Common::ClassDef.create(
              self, backtrack_class_def_offset
            )
          end

          def input_class_def
            @input_class_def ||= Common::ClassDef.create(
              self, input_class_def_offset
            )
          end

          def lookahead_class_def
            @lookahead_class_def ||= Common::ClassDef.create(
              self, lookahead_class_def_offset
            )
          end

          def max_context
            @max_context ||= chain_sub_class_sets.flat_map do |chain_sub_class_set|
              chain_sub_class_set.chain_sub_class_rules.map do |chain_sub_class_rule|
                chain_sub_class_rule.input_glyph_ids.count +
                  chain_sub_class_rule.lookahead_glyph_ids.count
              end
            end.max
          end

          def dependent_coverage_tables
            [coverage_table]
          end

          def encode
            EncodedString.create do |result|
              result.write(format, 'n')
              result << ph(:gsub, coverage_table.id, 2, relative_to: 0)
              result << ph(:gsub, backtrack_class_def.id, 2)
              result << ph(:gsub, input_class_def.id, 2)
              result << ph(:gsub, lookahead_class_def.id, 2)
              result << chain_sub_class_sets.encode do |chain_sub_class_set|
                [ph(:gsub, chain_sub_class_set.id, 2)]
              end

              result.resolve_placeholders(:gsub, backtrack_class_def.id, [result.length].pack('n'))
              result << backtrack_class_def.encode
              result.resolve_placeholders(:gsub, input_class_def.id, [result.length].pack('n'))
              result << input_class_def.encode
              result.resolve_placeholders(:gsub, lookahead_class_def.id, [result.length].pack('n'))
              result << lookahead_class_def.encode

              chain_sub_class_sets.each do |chain_sub_class_set|
                result.resolve_placeholders(
                  :gsub, chain_sub_class_set.id, [result.length].pack('n')
                )

                result << chain_sub_class_set.encode
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
            @length + sum(chain_sub_class_sets, &:length)
          end

          private

          def parse!
            @format, @coverage_offset, @backtrack_class_def_offset,
              @input_class_def_offset, @lookahead_class_def_offset,
              count = read(12, 'n6')

            @chain_sub_class_sets = Sequence.from(io, count, 'n') do |chain_sub_class_set_offset|
              Gsub::ChainSubClassSet.new(file, table_offset + chain_sub_class_set_offset)
            end

            @length = 12 + chain_sub_class_sets.length
          end
        end
      end
    end
  end
end
