module TTFunk
  class Table
    module Common
      class ClassDef1 < TTFunk::SubTable
        attr_reader :format, :start_glyph_id, :class_values

        private

        def parse!
          @format, @start_glyph_id, count = read(6, 'n')
          @class_values = Sequence.new(io, count, 'n')
          @length = 6 + class_values.length
        end
      end
    end
  end
end
