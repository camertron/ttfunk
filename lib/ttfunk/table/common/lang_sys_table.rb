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
          EncodedString.new do |result|
            result << [lookup_order, required_feature_index, feature_indices.count].pack('nnn')
            feature_indices.encode_to(result)
          end
        end

        private

        def parse!
          # lookup order is a reserved field and should always be null (0)
          @lookup_order, @required_feature_index, count = read(6, 'nnn')
          @feature_indices = Sequence.from(io, count, 'n')
          @length = 6 + feature_indices.length
        end
      end
    end
  end
end
