module TTFunk
  class Table
    class Gsub
      class Chaining2 < TTFunk::SubTable
        attr_reader :format, :coverage_offset, :backtrack_class_def_offset
        attr_reader :input_class_def_offset, :lookahead_class_def_offset

        def coverage_table
          @coverage_table ||= CoverageTable.create(
            file, self, table_offset + coverage_offset
          )
        end

        def backtrack_class_def
          @backtrack_class_def ||= ClassDef.create(
            self, backtrack_class_def_offset
          )
        end

        def input_class_def
          @input_class_def ||= ClassDef.create(
            self, input_class_def_offset
          )
        end

        def lookahead_class_def
          @lookahead_class_def ||= ClassDef.create(
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

        private

        def parse!
          @format, @coverage_offset, @backtrack_class_def_offset,
            @input_class_def_offset, @lookahead_class_def_offset,
            count = read(12, 'n6')

          @chain_sub_class_sets = Sequence.from(io, count, 'n') do |chain_sub_class_set_offset|
            ChainSubClassSet.new(file, table_offset + chain_sub_class_set_offset)
          end

          @length = 12 + chain_sub_class_sets.length
        end
      end
    end
  end
end
