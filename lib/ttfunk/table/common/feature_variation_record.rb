module TTFunk
  class Table
    module Common
      class FeatureVariationTable < TTFunk::SubTable
        include Enumerable

        RECORD_LENGTH = 2

        attr_reader :feature_variation_list
        attr_reader :condition_set_offset, :feature_table_substitution_offset

        def initialize(
          feature_variation_list,
          condition_set_offset,
          feature_table_substitution_offset)

          @feature_variation_list = feature_variation_list
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
      end
    end
  end
end
