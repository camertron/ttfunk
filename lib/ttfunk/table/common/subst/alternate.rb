module TTFunk
  class Table
    module Common
      module Subst
        class Alternate < TTFunk::SubTable
          ALTERNATE_SET_OFFSET_LENGTH = 2

          attr_reader :format, :coverage_offset, :alternate_sets

          def self.create(file, offset)
            new(file, offset)
          end

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'nnn')
            alternate_set_offset_array = io.read(count * GLYPH_ID_LENGTH)

            @alternate_sets = Sequence.new(alternate_set_offset_array, ALTERNATE_SET_OFFSET_LENGTH) do |offset_data|
              alternate_set_offset = offset_data.unpack('n').first
              AlternateSet.new(file, table_offset + alternate_set_offset)
            end

            @length = 6 + alternate_sets.length
          end
        end
      end
    end
  end
end
