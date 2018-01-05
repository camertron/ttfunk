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
          @lookup_indices = Sequence.from(io, count, 'n')
          @length = 4 + lookup_indices.length
        end
      end
    end
  end
end
