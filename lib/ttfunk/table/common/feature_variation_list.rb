module TTFunk
  class Table
    module Common
      class FeatureVariationList < TTFunk::SubTable
        include Enumerable

        FEATURE_VARIATION_RECORD_LENGTH = 8

        attr_reader :major_version, :minor_version, :count

        def each
          return to_enum(__method__) unless block_given?
          count.times { |i| yield self[i] }
        end

        def [](index)
          feature_variation_tables[index] ||= begin
            offset = index * FEATURE_VARIATION_RECORD_LENGTH

            variation_record_data = @raw_record_array[
              offset, FEATURE_VARIATION_RECORD_LENGTH
            ]

            condition_set_offset, feature_table_substitution_offset =
              variation_record_data.unpack('NN')

            FeatureVariationRecord.new(
              self, condition_set_offset, feature_table_substitution_offset
            )
          end
        end

        private

        def parse!
          @major_version, @minor_version, @count = read(8, 'nnN')
          @raw_record_array = io.read(count * FEATURE_VARIATION_RECORD_LENGTH)
          @length = 8 + @raw_record_array.length
        end

        def feature_variation_tables
          @feature_variation_tables ||= {}
        end
      end
    end
  end
end
