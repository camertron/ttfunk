require_relative './layout'

module TTFunk
  class Table
    class Gpos < Layout
      autoload :ComponentTable,      'ttfunk/table/gpos/component_table'
      autoload :BaseArray,           'ttfunk/table/gpos/base_array'
      autoload :BaseTable,           'ttfunk/table/gpos/base_table'
      autoload :EntryExitTable,      'ttfunk/table/gpos/entry_exit_table'
      autoload :LigatureArray,       'ttfunk/table/gpos/ligature_array'
      autoload :LigatureAttachTable, 'ttfunk/table/gpos/ligature_attach_table'
      autoload :Lookup,              'ttfunk/table/gpos/lookup'
      autoload :MarkArray,           'ttfunk/table/gpos/mark_array'
      autoload :MarkTable,           'ttfunk/table/gpos/mark_table'
      autoload :PairSet,             'ttfunk/table/gpos/pair_set'
      autoload :PairValueTable,      'ttfunk/table/gpos/pair_value_table'
      autoload :ValueTable,          'ttfunk/table/gpos/value_table'

      TAG = 'GPOS'.freeze
      LOOKUP_TABLE = Gpos::Lookup::LookupTable

      def tag
        TAG
      end
    end
  end
end
