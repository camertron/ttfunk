module TTFunk
  class Table
    class Gpos
      class PosLookupTable < TTFunk::SubTable
        FORMAT = 'nn'

        attr_reader :sequence_index, :lookup_list_index

        def encode
          EncodedString.new do |result|
            result << [sequence_index, lookup_list_index].pack(FORMAT)
          end
        end

        private

        def parse!
          @sequence_index, @lookup_list_index = read(4, FORMAT)
          @length = 4
        end
      end
    end
  end
end
