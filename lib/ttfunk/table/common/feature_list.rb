module TTFunk
  class Table
    module Common
      class FeatureList < TTFunk::SubTable
        attr_reader :tables

        def encode
          EncodedString.create do |result|
            result.write(tables.count, 'n')
            tables.encode_to(result) do |table|
              [table.tag, ph(:common, table.id, length: 2)]
            end

            tables.each do |table|
              result.resolve_placeholders(:common, table.id, [result.length].pack('n'))
              result << table.encode
            end
          end
        end

        def length
          @length + sum(tables, &:length)
        end

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
