module TTFunk
  class Table
    module Common
      class FeatureTableSubstitutionList < TTFunk::SubTable
        include Enumerable

        FEATURE_TABLE_SUBSTITUTION_RECORD_LENGTH = 6

        def [](index)
          feature_table_substitutions[index] ||= begin
            offset = index * FEATURE_TABLE_SUBSTITUTION_RECORD_LENGTH

            feature_table_index, alternate_feature_table_offset =
              @raw_record_array[offset, FEATURE_TABLE_SUBSTITUTION_RECORD_LENGTH].unpack('nN')

            FeatureTableSubstitutionRecord.new(
              file, feature_table_index, table_offset + alternate_feature_table_offset
            )
          end
        end

        def each
          return to_enum(__method__) unless block_given?
          count.times { |i| yield self[i] }
        end

        private

        def parse!
          @major_version, @minor_version, @count = read(6, 'nnn')
          @raw_record_array = read(count * FEATURE_TABLE_SUBSTITUTION_RECORD_LENGTH)
          @length = 6 + @raw_record_array.length
        end

        def feature_table_substitutions
          @feature_table_substitutions ||= {}
        end
      end
    end
  end
end
