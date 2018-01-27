module TTFunk
  class Table
    class Gpos
      class PosLookupTable
        FORMAT = 'nn'

        attr_reader :length, :sequence_index, :lookup_list_index

        def self.create_sequence(io, count)
          Sequence.from(io, count, FORMAT) { |*args| new(*args) }
        end

        def initialize(*args)
          @sequence_index, @lookup_list_index = args
          @length = 4
        end
      end
    end
  end
end
