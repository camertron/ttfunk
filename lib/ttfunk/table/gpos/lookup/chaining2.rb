module TTFunk
  class Table
    class Gpos
      module Lookup
        class Chaining2 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :backtrack_class_def_offset
          attr_reader :input_class_def_offset, :lookahead_class_def_offset
          attr_reader :chain_pos_class_sets

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
