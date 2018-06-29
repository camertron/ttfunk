module TTFunk
  class Table
    class Gpos
      module Lookup
        class Chaining2 < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :backtrack_class_def_offset
          attr_reader :input_class_def_offset, :lookahead_class_def_offset
          attr_reader :chain_pos_class_sets

          def backtrack_class_def
            @backtrack_class_def ||= Common::ClassDef.create(
              self, table_offset + backtrack_class_def_offset
            )
          end

          def input_class_def
            @input_class_def ||= Common::ClassDef.create(
              self, table_offset + input_class_def_offset
            )
          end

          def lookahead_class_def
            @lookahead_class_def ||= Common::ClassDef.create(
              self, table_offset + lookahead_class_def_offset
            )
          end

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << coverage_table.placeholder
              result << backtrack_class_def.placeholder
              result << input_class_def.placeholder
              result << lookahead_class_def.placeholder
              result << chain_pos_class_sets.encode_to(result) do |chain_pos_class_set|
                next [0] unless chain_pos_class_set
                [chain_pos_class_set.placeholder]
              end

              # Although not mentioned anywhere in the documentation, class
              # defs can be shared between backtrack, input, and lookahead.
              # This means there could be more than one placeholder per
              # class def table ID, necessitating the use of resolve_each.
              result.resolve_each(backtrack_class_def.id) do
                [result.length].pack('n')
              end

              result << backtrack_class_def.encode

              result.resolve_each(input_class_def.id) do
                [result.length].pack('n')
              end

              result << input_class_def.encode

              result.resolve_each(lookahead_class_def.id) do
                [result.length].pack('n')
              end

              result << lookahead_class_def.encode

              chain_pos_class_sets.each do |chain_pos_class_set|
                next unless chain_pos_class_set

                result.resolve_placeholder(
                  chain_pos_class_set.id, [result.length].pack('n')
                )

                result << chain_pos_class_set.encode
              end
            end
          end

          def length
            @length + sum(chain_pos_class_sets) { |cpcs| cpcs&.length || 0 }
          end

          private

          def parse!
            @format, @coverage_offset, @backtrack_class_def_offset,
              @input_class_def_offset, @lookahead_class_def_offset,
              count = read(12, 'n6')

            @chain_pos_class_sets = Sequence.from(io, count, 'n') do |chain_pos_class_set_offset|
              ChainPosClassSet.new(table_offset + chain_pos_class_set_offset)
            end

            @length = 12 + chain_pos_class_sets.length
          end
        end
      end
    end
  end
end
