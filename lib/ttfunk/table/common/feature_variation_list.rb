module TTFunk
  class Table
    module Common
      class FeatureVariationList < TTFunk::SubTable
        attr_reader :major_version, :minor_version, :tables

        def encode
          EncodedString.create do |result|
            result.write([major_version, minor_version, tables.count], 'nnn')
            result << tables.encode do |table|
              [
                ph(:common, table.condition_set.id, 4),
                ph(:common, table.feature_table_substitutions.id, 4)
              ]
            end

            tables.each do |table|
              result.resolve_placeholder(
                :common, table.condition_set.id, [result.length].encode('N')
              )

              result << table.condition_set.encode

              result.resolve_placeholder(
                :common, table.feature_table_substitutions.id, [result.length].encode('N')
              )

              result << table.feature_table_substitutions.encode
            end
          end
        end

        private

        def parse!
          @major_version, @minor_version, count = read(8, 'nnN')

          @tables = Sequence.from(io, count, 'NN') do |condition_set_offset, feature_table_sub_offset|
            FeatureVariationTable.new(
              self,
              table_offset + condition_set_offset,
              table_offset + feature_table_sub_offset
            )
          end

          @length = 8 + tables.length
        end
      end
    end
  end
end
