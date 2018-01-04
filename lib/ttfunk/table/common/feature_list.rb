module TTFunk
  class Table
    module Common
      class FeatureList < TTFunk::SubTable
        FEATURE_RECORD_LENGTH = 6

        attr_reader :records

        private

        def parse!
          count = read(2, 'n').first
          feature_record_array = io.read(count * FEATURE_RECORD_LENGTH)

          @records = Sequence.new(feature_record_array, FEATURE_RECORD_LENGTH) do |feature_record|
            tag, feature_offset = feature_record.unpack('A4n')
            FeatureTable.new(file, tag, table_offset + feature_offset)
          end

          @length = 2 + records.length
        end
      end
    end
  end
end
