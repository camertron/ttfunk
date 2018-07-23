module TTFunk
  class Table
    module Common
      class FeatureList < TTFunk::SubTable
        attr_reader :tables

        def encode(old2new_lookups, old2new_features)
          EncodedString.new do |result|
            result << [old2new_features.count].pack('n')

            old2new_features.each do |old_index, _|
              table = tables[old_index]
              result << [table.tag].pack('A4')
              result << table.placeholder
            end

            old2new_features.each do |old_index, _|
              table = tables[old_index]
              result.resolve_placeholder(table.id, [result.length].pack('n'))
              result << table.encode(old2new_lookups)
            end
          end
        end

        def length
          @length + sum(tables, &:length)
        end

        def old2new_features_for(old2new_lookups)
          old_lookup_indices = old2new_lookups.keys
          new_index = 0

          {}.tap do |old2new_features|
            tables.each_with_index do |table, old_index|
              next unless (table.lookup_indices.to_a & old_lookup_indices).any?
              old2new_features[old_index] = new_index
              new_index += 1
            end
          end
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
