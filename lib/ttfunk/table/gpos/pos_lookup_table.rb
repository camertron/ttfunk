module TTFunk
  class Table
    class Gpos
      class PosLookupTable < TTFunk::SubTable
        FORMAT = 'nn'

        attr_reader :sequence_index, :lookup_list_index

        private

        def parse!
          @sequence_index, @lookup_list_index = read(4, FORMAT)
          @length = 4
        end
      end
    end
  end
end
