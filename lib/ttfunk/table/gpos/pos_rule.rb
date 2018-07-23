module TTFunk
  class Table
    class Gpos
      class PosRule < TTFunk::SubTable
        attr_reader :input_sequence, :pos_lookup_tables

        def encode
          EncodedString.new do |result|
            result << [input_sequence.count, pos_lookup_tables.size].pack('n*')
            input_sequence.encode_to(result)
            pos_lookup_tables.each do |pos_lookup_table|
              result << pos_lookup_table.encode
            end
          end
        end

        private

        def parse!
          glyph_count, pos_count = read(4, 'nn')

          @input_sequence = Sequence.from(io, glyph_count - 1, 'n')
          @pos_lookup_tables = Array.new(pos_count) do
            PosLookupTable.new(file, io.pos)
          end

          @length = 4 +
            sum(input_sequence, &:length) +
            sum(pos_lookup_tables, &:length)
        end
      end
    end
  end
end
