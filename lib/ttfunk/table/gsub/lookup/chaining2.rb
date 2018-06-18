module TTFunk
  class Table
    class Gsub
      module Lookup
        class Chaining2 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :lookup_type
          attr_reader :format, :coverage_offset, :backtrack_class_def_offset
          attr_reader :input_class_def_offset, :lookahead_class_def_offset
          attr_reader :chain_sub_class_sets

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
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
            EncodedString.new do |result|
              result << [format].pack('n')
              result << Placeholder.new("gsub_#{coverage_table.id}", length: 2, relative_to: 0)
              result << Placeholder.new("gsub_#{backtrack_class_def.id}", length: 2)
              result << Placeholder.new("gsub_#{input_class_def.id}", length: 2)
              result << Placeholder.new("gsub_#{lookahead_class_def.id}", length: 2)
              result << chain_sub_class_sets.encode do |chain_sub_class_set|
                if chain_sub_class_set
                  [Placeholder.new("gsub_#{chain_sub_class_set.id}", length: 2)]
                else
                  [0]
                end
              end

              result.resolve_placeholder("gsub_#{backtrack_class_def.id}", [result.length].pack('n'))
              result << backtrack_class_def.encode
              result.resolve_placeholder("gsub_#{input_class_def.id}", [result.length].pack('n'))
              result << input_class_def.encode
              result.resolve_placeholder("gsub_#{lookahead_class_def.id}", [result.length].pack('n'))
              result << lookahead_class_def.encode

              chain_sub_class_sets.each do |chain_sub_class_set|
                next unless chain_sub_class_set

                result.resolve_placeholder(
                  "gsub_#{chain_sub_class_set.id}", [result.length].pack('n')
                )

                result << chain_sub_class_set.encode
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
            @length + sum(chain_sub_class_sets) { |cscs| cscs&.length || 0 }
          end

          private

          def parse!
            @format, @coverage_offset, @backtrack_class_def_offset,
              @input_class_def_offset, @lookahead_class_def_offset,
              count = read(12, 'n6')

            @chain_sub_class_sets = Sequence.from(io, count, 'n') do |chain_sub_class_set_offset|
              if chain_sub_class_set_offset > 0  # can be nil
                Gsub::ChainSubClassSet.new(file, table_offset + chain_sub_class_set_offset)
              end
            end

            @length = 12 + chain_sub_class_sets.length
          end
        end
      end
    end
  end
end
