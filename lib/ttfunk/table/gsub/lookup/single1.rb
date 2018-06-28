module TTFunk
  class Table
    class Gsub
      module Lookup
        class Single1 < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :delta_glyph_id

          def max_context
            1
          end

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << coverage_table.placeholder
              result << [delta_glyph_id].pack('n')
            end
          end

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
