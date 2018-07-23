module TTFunk
  class Table
    module Common
      class ClassDef1 < TTFunk::SubTable
        attr_reader :format, :start_glyph_id, :class_values

        def encode
          EncodedString.new do |result|
            result << [format, start_glyph_id, class_values.count].pack('nnn')
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
