module TTFunk
  class Table
    module Common
      module Subst
        class Single1 < TTFunk::SubTable
          attr_reader :format, :coverage_offset, :delta_glyph_id

          private

          def parse!
            @format, @coverage_offset, @delta_glyph_id = read(6, 'nnn')
            @length = 6
          end
        end
      end
    end
  end
end
