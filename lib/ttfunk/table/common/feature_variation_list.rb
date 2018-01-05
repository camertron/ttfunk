module TTFunk
  class Table
    module Common
      class FeatureVariationList < TTFunk::SubTable
        attr_reader :major_version, :minor_version, :tables

        private

        def parse!
          @major_version, @minor_version, count = read(8, 'nnN')

          @tables = Sequence.from(io, count, 'NN') do |condition_set_offset, feature_table_sub_offset|
            FeatureVariationRecord.new(
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
