module TTFunk
  class Table
    class Gsub
      class Chaining2 < TTFunk::SubTable
        attr_reader :format, :coverage_offset, :backtrack_class_def_offset
        attr_reader :input_class_def_offset, :lookahead_class_def_offset
        attr_reader :chain_sub_class_sets

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

        def encode
          EncodedString.create do |result|
            result.write(format, 'n')
            result << ph(:gsub, coverage_table.id, 2)
            result << ph(:gsub, backtrack_class_def.id, 2)
            result << ph(:gsub, input_class_def.id, 2)
            result << ph(:gsub, lookahead_class_def.id, 2)
            result << chain_sub_class_sets.encode do |chain_sub_class_set|
              [ph(:gsub, chain_sub_class_set.id, 2)]
            end

            result.resolve_placeholder(:gsub, backtrack_class_def.id, [result.length].pack('n'))
            result << backtrack_class_def.encode
            result.resolve_placeholder(:gsub, input_class_def.id, [result.length].pack('n'))
            result << input_class_def.encode
            result.resolve_placeholder(:gsub, lookahead_class_def.id, [result.length].pack('n'))
            result << lookahead_class_def.encode

            chain_sub_class_sets.each do |chain_sub_class_set|
              result.resolve_placeholder(
                :gsub, chain_sub_class_set.id, [result.length].pack('n')
              )

              result << chain_sub_class_set.encode
            end
          end
        end

        private

        def parse!
          @format, @coverage_offset, @backtrack_class_def_offset,
            @input_class_def_offset, @lookahead_class_def_offset,
            count = read(12, 'n6')

          @chain_sub_class_sets = Sequence.from(io, count, 'n') do |chain_sub_class_set_offset|
            Common::ChainSubClassSet.new(file, table_offset + chain_sub_class_set_offset)
          end

          @length = 12 + chain_sub_class_sets.length
        end
      end
    end
  end
end
