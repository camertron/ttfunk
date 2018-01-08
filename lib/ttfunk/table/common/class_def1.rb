module TTFunk
  class Table
    module Common
      class ClassDef1 < TTFunk::SubTable
        attr_reader :format, :start_glyph_id, :class_values

        def encode
          EncodedString.create do |result|
            result.write([format, start_glyph_id, class_values.length], 'nnn')
            result << class_values.encode
          end
        end

        private

        def parse!
          @format, @start_glyph_id, count = read(6, 'nnn')
          @class_values = Sequence.new(io, count, 'n')
          @length = 6 + class_values.length
        end
      end
    end
  end
end
