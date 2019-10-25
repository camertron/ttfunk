# frozen_string_literal: true

require_relative './layout'
require_relative './common'

module TTFunk
  class Table
    class Gsub < Layout
      autoload :AlternateSet,
        'ttfunk/table/gsub/alternate_set'
      autoload :ChainSubClassSet,
        'ttfunk/table/gsub/chain_sub_class_set'
      autoload :ChainSubClassRuleTable,
        'ttfunk/table/gsub/chain_sub_class_rule_table'
      autoload :ChainSubRuleSet,
        'ttfunk/table/gsub/chain_sub_rule_set'
      autoload :ChainSubRuleTable,
        'ttfunk/table/gsub/chain_sub_rule_table'
      autoload :ConditionSet,
        'ttfunk/table/gsub/condition_set'
      autoload :ConditionTable,
        'ttfunk/table/gsub/condition_table'
      autoload :LigatureSet,
        'ttfunk/table/gsub/ligature_set'
      autoload :LigatureTable,
        'ttfunk/table/gsub/ligature_table'
      autoload :Lookup,
        'ttfunk/table/gsub/lookup'
      autoload :SequenceTable,
        'ttfunk/table/gsub/sequence_table'
      autoload :SubClassRule,
        'ttfunk/table/gsub/sub_class_rule'
      autoload :SubClassSet,
        'ttfunk/table/gsub/sub_class_set'
      autoload :SubRule,
        'ttfunk/table/gsub/sub_rule'
      autoload :SubRuleSet,
        'ttfunk/table/gsub/sub_rule_set'
      autoload :SubstLookupTable,
        'ttfunk/table/gsub/subst_lookup_table'

      TAG = 'GSUB'
      LOOKUP_TABLE = Gsub::Lookup::LookupTable

      def tag
        TAG
      end

      def lookup_table
        LOOKUP_TABLE
      end
    end
  end
end
