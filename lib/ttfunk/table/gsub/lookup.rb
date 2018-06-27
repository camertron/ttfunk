module TTFunk
  class Table
    class Gsub
      module Lookup
        autoload :Alternate,       'ttfunk/table/gsub/lookup/alternate'
        autoload :Base,            'ttfunk/table/gsub/lookup/base'
        autoload :Chaining,        'ttfunk/table/gsub/lookup/chaining'
        autoload :Chaining1,       'ttfunk/table/gsub/lookup/chaining1'
        autoload :Chaining2,       'ttfunk/table/gsub/lookup/chaining2'
        autoload :Chaining3,       'ttfunk/table/gsub/lookup/chaining3'
        autoload :Contextual,      'ttfunk/table/gsub/lookup/contextual'
        autoload :Contextual1,     'ttfunk/table/gsub/lookup/contextual1'
        autoload :Contextual2,     'ttfunk/table/gsub/lookup/contextual2'
        autoload :Contextual3,     'ttfunk/table/gsub/lookup/contextual3'
        autoload :Extension,       'ttfunk/table/gsub/lookup/extension'
        autoload :Ligature,        'ttfunk/table/gsub/lookup/ligature'
        autoload :LookupTable,     'ttfunk/table/gsub/lookup/lookup_table'
        autoload :Multiple,        'ttfunk/table/gsub/lookup/multiple'
        autoload :ReverseChaining, 'ttfunk/table/gsub/lookup/reverse_chaining'
        autoload :Single,          'ttfunk/table/gsub/lookup/single'
        autoload :Single1,         'ttfunk/table/gsub/lookup/single1'
        autoload :Single2,         'ttfunk/table/gsub/lookup/single2'
      end
    end
  end
end
