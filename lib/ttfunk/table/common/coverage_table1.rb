# frozen_string_literal: true

module TTFunk
  class Table
    module Common
      class CoverageTable1 < TTFunk::SubTable
        attr_reader :format, :glyph_seq

        def encode
          EncodedString.new do |result|
            result << [format, glyph_ids.count].pack('nn')
            glyph_seq.encode_to(result)
          end
        end

        def glyph_ids
          @glyph_ids ||= glyph_seq.to_a
        end

        def placeholder_relative_to(tag_id)
          Placeholder.new(id, length: 2, relative_to: tag_id)
        end

        private

        def parse!
          @format, count = read(4, 'nn')
          @glyph_seq = Sequence.from(io, count, 'n')
          @length = 4 + glyph_ids.length
        end
      end
    end
  end
end
