module TTFunk
  class Table
    module Common
      class FeatureTable < TTFunk::SubTable
        LOOKUP_INDEX_LENGTH = 2

        attr_reader :tag, :feature_params_offset, :lookup_indices

        def initialize(file, tag, offset)
          @tag = tag
          super(file, offset)
        end

        private

        def parse!
          @feature_params_offset, count = read(4, 'nn')
          lookup_index_array = io.read(count * LOOKUP_INDEX_LENGTH)

          @lookup_indices = Sequence.new(lookup_index_array, LOOKUP_INDEX_LENGTH) do |lookup_index|
            index_data.unpack('n').first
          end

          @length = 4 + lookup_indices.length
        end
      end
    end
  end
end
