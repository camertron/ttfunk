# frozen_string_literal: true

module TTFunk
  class Table
    class Gsub
      class SubstLookupTable
        # used by SubClassRule
        FORMAT = 'nn'

        attr_reader :glyph_sequence_index, :lookup_list_index

        def initialize(glyph_sequence_index, lookup_list_index)
          @glyph_sequence_index = glyph_sequence_index
          @lookup_list_index = lookup_list_index
        end
      end
    end
  end
end
