# frozen_string_literal: true

module TTFunk
  class Table
    module Common
      class FeatureVariationTable < TTFunk::SubTable
        attr_reader :condition_set_offset, :feature_table_substitution_offset

        def initialize(cs_offset, fts_offset)
          @condition_set_offset = cs_offset
          @feature_table_substitution_offset = fts_offset
        end

        def condition_set
          @condition_set ||= ConditionSet.new(
            file, table_offset + condition_set_offset
          )
        end

        def feature_table_substitutions
          @feature_table_substitutions ||= FeatureTableSubstitutionList.new(
            file, table_offset + feature_table_substitution_offset
          )
        end

        def length
          condition_set.length + feature_table_substitutions.length
        end
      end
    end
  end
end
