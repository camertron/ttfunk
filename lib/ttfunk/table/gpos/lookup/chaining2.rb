module TTFunk
  class Table
    class Gpos
      module Lookup
        class Chaining2 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :lookup_type
          attr_reader :format, :coverage_offset, :backtrack_class_def_offset
          attr_reader :input_class_def_offset, :lookahead_class_def_offset
          attr_reader :chain_pos_class_sets

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

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

          def dependent_coverage_tables
            [coverage_table]
          end

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << Placeholder.new("gpos_#{coverage_table.id}", length: 2, relative_to: 0)
              result << Placeholder.new("gpos_#{backtrack_class_def.id}", length: 2, relative_to: 0)
              result << Placeholder.new("gpos_#{input_class_def.id}", length: 2, relative_to: 0)
              result << Placeholder.new("gpos_#{lookahead_class_def.id}", length: 2, relative_to: 0)
              result << chain_pos_class_sets.encode_to(result) do |chain_pos_class_set|
                if chain_pos_class_set
                  [Placeholder.new("gpos_#{chain_pos_class_set.id}", length: 2, relative_to: 0)]
                else
                  [0]
                end
              end

              # Although not mentioned anywhere in the documentation, class
              # defs can be shared between backtrack, input, and lookahead.
              # This means there could be more than one placeholder per
              # class def table ID, necessitating the use of resolve_each.
              result.resolve_each("gpos_#{backtrack_class_def.id}") do
                [result.length].pack('n')
              end

              result << backtrack_class_def.encode

              result.resolve_each("gpos_#{input_class_def.id}") do
                [result.length].pack('n')
              end

              result << input_class_def.encode

              result.resolve_each("gpos_#{lookahead_class_def.id}") do
                [result.length].pack('n')
              end

              result << lookahead_class_def.encode

              chain_pos_class_sets.each do |chain_pos_class_set|
                next unless chain_pos_class_set

                result.resolve_placeholder(
                  "gpos_#{chain_pos_class_set.id}", [result.length].pack('n')
                )

                result << chain_pos_class_set.encode
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
