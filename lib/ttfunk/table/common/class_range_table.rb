module TTFunk
  class Table
    module Common
      class ClassRangeTable < TTFunk::SubTable
        attr_reader :start_glyph_id, :end_glyph_id, :class_id

        private

        def parse!
          @start_glyph_id, @end_glyph_id, @class_id = read(6, 'nnn')
          @length = 6
        end
      end
    end
  end
end
