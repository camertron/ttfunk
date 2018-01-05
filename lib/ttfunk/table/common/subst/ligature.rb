module TTFunk
  class Table
    module Common
      module Subst
        class Ligature < TTFunk::SubTable
          LIGATURE_SET_OFFSET_LENGTH = 2

          def self.create(file, offset)
            new(file, offset)
          end

          attr_reader :ligature_sets

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'nnn')
            ligature_set_offset_array = io.read(count * LIGATURE_SET_OFFSET_LENGTH)

            @ligature_sets = Sequence.new(ligature_set_offset_array, LIGATURE_SET_OFFSET_LENGTH) do |offset_data|
              ligature_set_offset = offset_data.unpack('n').first
              LigatureSet.new(file, table_offset + ligature_set_offset)
            end

            @length = 6 + ligature_sets.length
          end
        end
      end
    end
  end
end
