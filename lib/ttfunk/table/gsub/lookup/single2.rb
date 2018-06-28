module TTFunk
  class Table
    class Gsub
      module Lookup
        class Single2 < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :glyph_ids

          def max_context
            1
          end

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << coverage_table.placeholder
              result << [glyph_ids.count].pack('n')
              glyph_ids.encode_to(result)
            end
          end

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'nnn')
            @glyph_ids = Sequence.from(io, count, 'n')
            @length = 6 + glyph_ids.length
          end
        end
      end
    end
  end
end
