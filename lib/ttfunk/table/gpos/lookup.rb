module TTFunk
  class Table
    class Gpos
      module Lookup
        autoload :Cursive,         'ttfunk/table/gpos/lookup/cursive'
        autoload :LookupTable,     'ttfunk/table/gpos/lookup/lookup_table'
        autoload :MarkToBase,      'ttfunk/table/gpos/lookup/mark_to_base'
        autoload :MarkToLigature,  'ttfunk/table/gpos/lookup/mark_to_ligature'
        autoload :PairAdjustment,  'ttfunk/table/gpos/lookup/pair_adjustment'
        autoload :PairAdjustment1, 'ttfunk/table/gpos/lookup/pair_adjustment1'
        autoload :PairAdjustment2, 'ttfunk/table/gpos/lookup/pair_adjustment2'
        autoload :Single,          'ttfunk/table/gpos/lookup/single'
        autoload :Single1,         'ttfunk/table/gpos/lookup/single1'
        autoload :Single2,         'ttfunk/table/gpos/lookup/single2'
      end
    end
  end
end
