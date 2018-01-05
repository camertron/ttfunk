module TTFunk
  class Table
    module Common
      class FeatureTableSubstitutionList < TTFunk::SubTable
        attr_reader :tables

        private

        def parse!
          @major_version, @minor_version, count = read(6, 'nnn')

          @tables = Sequence.from(io, count, 'nN') do |feature_table_index, alt_feature_table_offset|
            FeatureTableSubstitutionRecord.new(
              file, feature_table_index, table_offset + alt_feature_table_offset
            )
          end

          @length = 6 + tables.length
        end
      end
    end
  end
end
