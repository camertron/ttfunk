# frozen_string_literal: true

module TTFunk
  class Table
    module Common
      class FeatureTableSubstitutionList < TTFunk::SubTable
        attr_reader :major_version, :minor_version, :tables

        def encode
          EncodedString.new do |result|
            result << [major_version, minor_version, tables.count].pack('nnn')
            tables.encode_to(result) do |table|
              [
                table.feature_table_index,
                table.alternate_feature_table.placeholder
              ]
            end

            tables.each do |table|
              result.resolve_placeholder(
                table.alternate_feature_table.id, [result.length].pack('N')
              )

              result << table.alternate_feature_table.encode
            end
          end
        end

        def length
          @length + sum(tables, &:length)
        end

        private

        def parse!
          @major_version, @minor_version, count = read(6, 'nnn')

          # feature table index, alt feature table offset
          @tables = Sequence.from(io, count, 'nN') do |ft_index, aft_offset|
            FeatureTableSubstitutionTable.new(
              file, ft_index, table_offset + aft_offset
            )
          end

          @length = 6 + tables.length
        end
      end
    end
  end
end
