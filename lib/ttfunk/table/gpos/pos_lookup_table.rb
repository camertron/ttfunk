module TTFunk
  class Table
    class Gpos
      class PosLookupRecord < TTFunk::SubTable
        attr_reader :sequence_index, :lookup_list_index

        private

        def parse!
          @sequence_index, @lookup_list_index = read(4, 'nn')
          @length = 4
        end
      end
    end
  end
end
