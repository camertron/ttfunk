module TTFunk
  class Table
    module Common
      class FeatureTableSubstitutionList < TTFunk::SubTable
        attr_reader :major_version, :minor_version, :tables

        def encode
          EncodedString.create do |result|
            result.write([major_version, minor_version, tables.count], 'nnn')
            result << tables.encode do |table|
              [
                table.feature_table_index,
                ph(:common, table.alternate_feature_table.id, length: 2)
              ]
            end

            tables.each do |table|
              result.resolve_placeholders(
                :common, table.alternate_feature_table.id, [result.length].pack('N')
              )

              result << table.alternate_feature_table.encode
            end
          end
        end

        private

        def parse!
          @major_version, @minor_version, count = read(6, 'nnn')

          @tables = Sequence.from(io, count, 'nN') do |feature_table_index, alt_feature_table_offset|
            FeatureTableSubstitutionTable.new(
              file, feature_table_index, table_offset + alt_feature_table_offset
            )
          end

          @length = 6 + tables.length
        end
      end
    end
  end
end
