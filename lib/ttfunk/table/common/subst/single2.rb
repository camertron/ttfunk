module TTFunk
  class Table
    module Common
      module Subst
        class Single2 < TTFunk::SubTable
          GLYPH_ID_LENGTH = 2

          attr_reader :format, :coverage_offset, :glyph_ids

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'nnn')
            glyph_id_array = io.read(count * GLYPH_ID_LENGTH)

            @glyph_ids = Sequence.new(glyph_id_array, GLYPH_ID_LENGTH) do |glyph_data|
              glyph_data.unpack('n').first
            end

            @length = 6 + glyph_ids.length
          end
        end
      end
    end
  end
end
