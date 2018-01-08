module TTFunk
  class Table
    module Common
      class FeatureTableSubstitutionTable
        attr_reader :file, :feature_table_index, :alternate_feature_table_offset

        def encode
          EncodedString.create do |result|
            result << alternate_feature_table.encode
          end
        end

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
