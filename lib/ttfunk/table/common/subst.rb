module TTFunk
  class Table
    module Common
      module Subst
        autoload :Multiple,      'ttfunk/table/common/subst/multiple'
        autoload :SequenceTable, 'ttfunk/table/common/subst/sequence_table'
        autoload :Single,        'ttfunk/table/common/subst/single'
        autoload :Single1,       'ttfunk/table/common/subst/single1'
        autoload :Single2,       'ttfunk/table/common/subst/single2'
      end
    end
  end
end
