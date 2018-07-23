module TTFunk
  class Table
    module Common
      class FeatureTable < TTFunk::SubTable
        attr_reader :tag, :feature_params_offset, :lookup_indices

        def initialize(file, tag, offset)
          @tag = tag
          super(file, offset)
        end

        def encode(old2new_lookups)
          EncodedString.new do |result|
            subset_lookup_indices = old2new_lookups.keys & lookup_indices.to_a
            result << [feature_params_offset, subset_lookup_indices.count].pack('nn')
            result << subset_lookup_indices
              .map { |lookup_index| old2new_lookups[lookup_index] }
              .pack('n*')
          end
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
