module TTFunk
  class Table
    module Common
      class FeatureList < TTFunk::SubTable
        include Enumerable

        FEATURE_RECORD_LENGTH = 6

        attr_reader :count

        def each
          return to_enum(__method__) unless block_given?
          count.times { |i| yield self[i] }
        end

        def [](index)
          feature_tables[index] ||= begin
            offset = index * FEATURE_RECORD_LENGTH
            tag, feature_offset = @raw_record_array[offset, FEATURE_RECORD_LENGTH].unpack('A4n')
            FeatureTable.new(file, tag, table_offset + feature_offset)
          end
        end

        private

        def parse!
          @count = read(2, 'n').first
          @raw_record_array = io.read(count * FEATURE_RECORD_LENGTH)
          @length = 2 + @raw_record_array.length
        end

        def feature_tables
          @feature_tables ||= {}
        end
      end
    end
  end
end
