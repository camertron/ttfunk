module TTFunk
  class Table
    module Common
      class FeatureTableSubstitutionList < TTFunk::SubTable
        FEATURE_TABLE_SUBSTITUTION_RECORD_LENGTH = 6

        attr_reader :records

        private

        def parse!
          @major_version, @minor_version, count = read(6, 'nnn')
          feature_substitution_array = read(count * FEATURE_TABLE_SUBSTITUTION_RECORD_LENGTH)

          @records = Sequence.new(feature_substitution_array, FEATURE_TABLE_SUBSTITUTION_RECORD_LENGTH) do |feature_data|
            feature_table_index, alternate_feature_table_offset = feature_data.unpack('nN')

            FeatureTableSubstitutionRecord.new(
              file, feature_table_index, table_offset + alternate_feature_table_offset
            )
          end

          @length = 6 + records.length
        end
      end
    end
  end
end
