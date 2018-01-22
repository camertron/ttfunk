require_relative './layout'
require_relative './common'

module TTFunk
  class Table
    class Gpos < Layout
      autoload :AnchorTable,         'ttfunk/table/gpos/anchor_table'
      autoload :AnchorTable1,        'ttfunk/table/gpos/anchor_table1'
      autoload :AnchorTable2,        'ttfunk/table/gpos/anchor_table2'
      autoload :AnchorTable3,        'ttfunk/table/gpos/anchor_table3'
      autoload :ChainPosClassRule,   'ttfunk/table/gpos/chain_pos_class_rule'
      autoload :ChainPosClassSet,    'ttfunk/table/gpos/chain_pos_class_set'
      autoload :ChainPosRule,        'ttfunk/table/gpos/chain_pos_rule'
      autoload :ChainPosRuleSet,     'ttfunk/table/gpos/chain_pos_rule_set'
      autoload :Class2,              'ttfunk/table/gpos/class2'
      autoload :ComponentTable,      'ttfunk/table/gpos/component_table'
      autoload :BaseArray,           'ttfunk/table/gpos/base_array'
      autoload :BaseTable,           'ttfunk/table/gpos/base_table'
      autoload :EntryExitTable,      'ttfunk/table/gpos/entry_exit_table'
      autoload :LigatureArray,       'ttfunk/table/gpos/ligature_array'
      autoload :LigatureAttachTable, 'ttfunk/table/gpos/ligature_attach_table'
      autoload :Lookup,              'ttfunk/table/gpos/lookup'
      autoload :MarkArray,           'ttfunk/table/gpos/mark_array'
      autoload :Mark2Array,          'ttfunk/table/gpos/mark2_array'
      autoload :MarkTable,           'ttfunk/table/gpos/mark_table'
      autoload :Mark2Table,          'ttfunk/table/gpos/mark2_table'
      autoload :PairSet,             'ttfunk/table/gpos/pair_set'
      autoload :PairValueTable,      'ttfunk/table/gpos/pair_value_table'
      autoload :PosClassRule,        'ttfunk/table/gpos/pos_class_rule'
      autoload :PosClassSet,         'ttfunk/table/gpos/pos_class_set'
      autoload :PosLookupTable,      'ttfunk/table/gpos/pos_lookup_table'
      autoload :PosRule,             'ttfunk/table/gpos/pos_rule'
      autoload :PosRuleSet,          'ttfunk/table/gpos/pos_rule_set'
      autoload :ValueTable,          'ttfunk/table/gpos/value_table'

      TAG = 'GPOS'.freeze
      LOOKUP_TABLE = Gpos::Lookup::LookupTable

      def tag
        TAG
      end

      def lookup_table
        LOOKUP_TABLE
      end

      def self.encode(gpos)
        gpos.raw
      end
    end
  end
end
