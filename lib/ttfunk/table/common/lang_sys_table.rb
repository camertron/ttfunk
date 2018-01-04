module TTFunk
  class Table
    module Common
      class LangSysTable < TTFunk::SubTable
        FEATURE_INDEX_LENGTH = 2

        attr_reader :tag, :lookup_order, :required_feature_index, :feature_indices

        def initialize(file, tag, offset)
          @tag = tag
          super(file, offset)
        end

        private

        def parse!
          @lookup_order, @required_feature_index, count = read(6, 'nnn')
          lookup_index_array = io.read(count * FEATURE_INDEX_LENGTH)

          @feature_indices = Sequence.new(lookup_index_array, FEATURE_INDEX_LENGTH) do |feature_index_data|
            feature_index_data.unpack('n').first
          end

          @length = 6 + feature_indices.length
        end
      end
    end
  end
end
