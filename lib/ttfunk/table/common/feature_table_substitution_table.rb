# frozen_string_literal: true

module TTFunk
  class Table
    module Common
      class FeatureTableSubstitutionTable
        attr_reader :file
        attr_reader :feature_table_index, :alternate_feature_table_offset

        def encode
          EncodedString.new do |result|
            result << alternate_feature_table.encode
          end
        end

        def initialize(file, ft_index, aft_offset)
          @file = file
          @feature_table_index = ft_index
          @alternate_feature_table_offset = aft_offset
        end

        def alternate_feature_table
          @alternate_feature_table ||= FeatureTable.new(
            file, table_offset + alternate_feature_table_offset
          )
        end

        def length
          6 + alternate_feature_table.length
        end
      end
    end
  end
end
