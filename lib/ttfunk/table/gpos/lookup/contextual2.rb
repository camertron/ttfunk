module TTFunk
  class Table
    class Gpos
      module Lookup
        class Contextual2 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :class_def_offset
          attr_reader :pos_class_sets

          def class_def
            @class_def ||= Common::ClassDef.new(
              file, table_offset + class_def_offset
            )
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
