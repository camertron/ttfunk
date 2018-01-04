module TTFunk
  class Table
    module Common
      class FeatureVariationList < TTFunk::SubTable
        FEATURE_VARIATION_RECORD_LENGTH = 8

        attr_reader :major_version, :minor_version, :records

        private

        def parse!
          @major_version, @minor_version, count = read(8, 'nnN')
          feature_variation_array = io.read(count * FEATURE_VARIATION_RECORD_LENGTH)

          @records = Sequence.new(feature_variation_array, FEATURE_VARIATION_RECORD_LENGTH) do |feature_variation_data|
            condition_set_offset, feature_table_substitution_offset =
              feature_variation_data.unpack('NN')

            FeatureVariationRecord.new(
              self,
              table_offset + condition_set_offset,
              table_offset + feature_table_substitution_offset
            )
          end

          @length = 8 + records.length
        end
      end
    end
  end
end
