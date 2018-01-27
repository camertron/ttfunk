module TTFunk
  class Table
    module Common
      class ClassRangeTable
        FORMAT = 'nnn'

        attr_reader :start_glyph_id, :end_glyph_id, :class_id, :length

        def self.create_sequence(io, count)
          Sequence.from(io, count, FORMAT) { |*args| new(*args) }
        end

        def initialize(*args)
          @start_glyph_id, @end_glyph_id, @class_id = args
          @length = 6
        end

        def encode
          EncodedString.create do |result|
            result.write([start_glyph_id, end_glyph_id, class_id], FORMAT)
          end
        end
      end
    end
  end
end
