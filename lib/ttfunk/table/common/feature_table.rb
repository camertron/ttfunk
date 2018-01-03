module TTFunk
  class Table
    module Common
      class FeatureTable < TTFunk::SubTable
        include Enumerable

        LOOKUP_INDEX_LENGTH = 2

        attr_reader :tag, :feature_params_offset, :count

        def initialize(file, tag, offset)
          @tag = tag
          super(file, offset)
        end

        def each
          return to_enum(__method__) unless block_given?
          count.times { |i| yield self[i] }
        end

        def [](index)
          indices[index] ||= begin
            index_data = @raw_lookup_indices[
              index * LOOKUP_INDEX_LENGTH, LOOKUP_INDEX_LENGTH
            ]

            index_data.unpack('n').first
          end
        end

        private

        def parse!
          @feature_params, @count = read(4, 'nn')
          @raw_lookup_indices = io.read(count * LOOKUP_INDEX_LENGTH)
          @length = 4 + @raw_lookup_indices.length
        end

        def indices
          @indices ||= []
        end
      end
    end
  end
end
