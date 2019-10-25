# frozen_string_literal: true

module TTFunk
  class Table
    module Common
      class FeatureVariationList < TTFunk::SubTable
        attr_reader :major_version, :minor_version, :tables

        def encode
          EncodedString.new do |result|
            result << [major_version, minor_version, tables.count].pack('nnn')
            tables.encode_to(result) do |table|
              [
                Placeholder.new(table.condition_set.id, length: 4),
                Placeholder.new(table.feature_table_substitutions.id, length: 4)
              ]
            end

            tables.each do |table|
              result.resolve_placeholder(
                table.condition_set.id, [result.length].pack('N')
              )

              result << table.condition_set.encode

              result.resolve_placeholder(
                table.feature_table_substitutions.id, [result.length].pack('N')
              )

              result << table.feature_table_substitutions.encode
            end
          end
        end

        def length
          @length + sum(tables, &:length)
        end

        private

        def parse!
          @major_version, @minor_version, count = read(8, 'nnN')

          # condition set offset, feature table sub offset
          @tables = Sequence.from(io, count, 'NN') do |cs_offset, fts_offset|
            FeatureVariationTable.new(
              self,
              table_offset + cs_offset,
              table_offset + fts_offset
            )
          end

          @length = 8 + tables.length
        end
      end
    end
  end
end
