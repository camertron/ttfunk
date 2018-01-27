module TTFunk
  class Table
    class Gsub
      class ClassDef1 < TTFunk::SubTable
        attr_reader :format, :start_glyph_id, :class_values

        def encode
          EncodedString.create do |result|
            result.write([format, start_glyph_id, class_values.count], 'nnn')
            class_values.encode_to(result)
          end
        end

        private

        def parse!
          @format, @start_glyph_id, count = read(6, 'nnn')
          @class_values = Sequence.from(io, count, 'n')
          @length = 6 + class_values.length
        end
      end
    end
  end
end
