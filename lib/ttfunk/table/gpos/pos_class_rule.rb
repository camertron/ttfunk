module TTFunk
  class Table
    class Gpos
      class PosClassRule < TTFunk::SubTable
        attr_reader :classes, :pos_lookups

        def encode
          EncodedString.new do |result|
            result << [classes.count, pos_lookups.size].pack('n*')
            classes.encode_to(result)
            pos_lookups.each { |pos_lookup| result << pos_lookup.encode }
          end
        end

        private

        def parse!
          glyph_count, pos_count = read(4, 'nn')

          @classes = Sequence.from(io, glyph_count - 1, 'n')
          @pos_lookups = Array.new(pos_count) do
            PosLookupTable.new(file, io.pos)
          end

          @length = 4 +
            sum(classes, &:length) +
            sum(pos_lookups, &:length)
        end
      end
    end
  end
end
