module TTFunk
  class Table
    module Common
      class SubstLookupTable
        FORMAT = 'nn'  # used by SubClassRule

        attr_reader :glyph_sequence_index, :lookup_list_index

        def initialize(glyph_sequence_index, lookup_list_index)
          @glyph_sequence_index = glyph_sequence_index
          @lookup_list_index = lookup_list_index
        end
      end
    end
  end
end
