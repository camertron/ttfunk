module TTFunk
  class Table
    module Common
      class FeatureVariationTable < TTFunk::SubTable
        attr_reader :condition_set_offset, :feature_table_substitution_offset

        def initialize(condition_set_offset, feature_table_substitution_offset)
          @condition_set_offset = condition_set_offset
          @feature_table_substitution_offset = feature_table_substitution_offset
        end

        def condition_set
          @condition_set ||= ConditionSet.new(file, table_offset + condition_set_offset)
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
