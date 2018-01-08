module TTFunk
  class Table
    module Common
      class LangSysTable < TTFunk::SubTable
        attr_reader :tag, :lookup_order, :required_feature_index, :feature_indices

        def initialize(file, tag, offset)
          @tag = tag
          super(file, offset)
        end

        def encode
          EncodedString.create do |result|
            result.write([lookup_order, required_feature_index, feature_indices.count], 'nnn')
            result << feature_indices.encode
          end
        end

        private

        def parse!
          @lookup_order, @required_feature_index, count = read(6, 'nnn')
          @feature_indices = Sequence.from(io, count, 'n')
          @length = 6 + feature_indices.length
        end
      end
    end
  end
end
