module TTFunk
  class Table
    module Common
      class LangSysTable < TTFunk::SubTable
        EMPTY_REQUIRED_FEATURE_INDEX = 0xFFFF

        attr_reader :tag, :lookup_order, :required_feature_index, :feature_indices

        def initialize(file, tag, offset)
          @tag = tag
          super(file, offset)
        end

        def encode(old2new_features)
          EncodedString.new do |result|
            result << [lookup_order].pack('n')

            result << if has_required_feature?
              [old2new_features[required_feature_index]].pack('n')
            else
              [EMPTY_REQUIRED_FEATURE_INDEX].pack('n')
            end

            result << [feature_indices.count].pack('n')

            feature_indices.each do |feature_index|
              result << [old2new_features[feature_index]].pack('n')
            end
          end
        end

        def has_required_feature?
          required_feature_index != EMPTY_REQUIRED_FEATURE_INDEX
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
