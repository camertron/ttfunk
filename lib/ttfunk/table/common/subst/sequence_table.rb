module TTFunk
  class Table
    module Common
      module Subst
        class SequenceTable < TTFunk::SubTable
          GLYPH_ID_LENGTH = 2

          attr_reader :count

          def each
            return to_enum(__method__) unless block_given?
            count.times { |i| yield self[i] }
          end

          def [](index)
            substitute_glyph_ids[index] ||= begin
              offset = index * GLYPH_ID_LENGTH

              substitute_glyph_id_data = @raw_substitute_glyph_id_array[
                offset, GLYPH_ID_LENGTH
              ]

              substitute_glyph_id_data.unpack('n').first
            end
          end

          private

          def parse!
            @count = read(2, 'n').first
            @raw_substitute_glyph_id_array = io.read(count * GLYPH_ID_LENGTH)
          end

          def substitute_glyph_ids
            @substitute_glyph_ids ||= {}
          end
        end
      end
    end
  end
end
