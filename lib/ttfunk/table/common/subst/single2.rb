module TTFunk
  class Table
    module Common
      module Subst
        class Single2 < TTFunk::SubTable
          include Enumerable

          SUBSTITUTE_GLYPH_ID_LENGTH = 2

          attr_reader :count

          def each
            return to_enum(__method__) unless block_given?
            count.times { |i| yield self[i] }
          end

          def [](index)
            substitute_glyph_ids[index] ||= begin
              offset = index * SUBSTITUTE_GLYPH_ID_LENGTH
              @raw_substitute_glyph_id_array[offset, SUBSTITUTE_GLYPH_ID_LENGTH].unpack('n').first
            end
          end

          private

          def parse!
            @format, @coverage_offset, @count = read(6, 'nnn')
            @raw_substitute_glyph_id_array = io.read(count * SUBSTITUTE_GLYPH_ID_LENGTH)
            @length = 6 + @raw_substitute_glyph_id_array.length
          end

          private

          def substitute_glyph_ids
            @substitute_glyph_ids ||= {}
          end
        end
      end
    end
  end
end
