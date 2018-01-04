module TTFunk
  class Table
    module Common
      class FeatureTableSubstitutionRecord
        attr_reader :file, :feature_table_index, :alternate_feature_table_offset

        def initialize(file, feature_table_index, alternate_feature_table_offset)
          @file = file
          @feature_table_index = feature_table_index
          @alternate_feature_table_offset = alternate_feature_table_offset
        end

        def alternate_feature_table
          @alternate_feature_table ||= FeatureTable.new(
            file, table_offset + alternate_feature_table_offset
          )
        end
      end
    end
  end
end
