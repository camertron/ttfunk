module TTFunk
  class Table
    module Common
      class FeatureVariationList < TTFunk::SubTable
        attr_reader :major_version, :minor_version, :tables

        def encode
          EncodedString.create do |result|
            result.write([major_version, minor_version, tables.count], 'nnn')
            tables.encode_to(result) do |table|
              [
                ph(:common, table.condition_set.id, length: 4),
                ph(:common, table.feature_table_substitutions.id, length: 4)
              ]
            end

            tables.each do |table|
              result.resolve_placeholders(
                :common, table.condition_set.id, [result.length].pack('N')
              )

              result << table.condition_set.encode

              result.resolve_placeholders(
                :common, table.feature_table_substitutions.id, [result.length].pack('N')
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
