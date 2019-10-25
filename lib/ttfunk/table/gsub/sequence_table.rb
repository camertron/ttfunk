# frozen_string_literal: true

module TTFunk
  class Table
    class Gsub
      class SequenceTable < TTFunk::SubTable
        attr_reader :glyph_ids

        def encode
          EncodedString.new do |result|
            result << [glyph_ids.count].pack('n')
            glyph_ids.encode_to(result)
          end
        end

        private

        def parse!
          count = read(2, 'n').first
          @glyph_ids = Sequence.from(io, count, 'n')
          @length = 2 + glyph_ids.length
        end
      end
    end
  end
end
