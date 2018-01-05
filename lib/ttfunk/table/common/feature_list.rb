module TTFunk
  class Table
    module Common
      class FeatureList < TTFunk::SubTable
        attr_reader :tables

        private

        def parse!
          count = read(2, 'n').first

          @tables = Sequence.from(io, count, 'A4n') do |tag, feature_offset|
            FeatureTable.new(file, tag, table_offset + feature_offset)
          end

          @length = 2 + tables.length
        end
      end
    end
  end
end
