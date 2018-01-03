module TTFunk
  class Table
    module Common
      class LangSysTable < TTFunk::SubTable
        include Enumerable

        FEATURE_INDEX_LENGTH = 2

        attr_reader :tag, :lookup_order, :required_feature_index, :count

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
            index_data = @raw_feature_indices[
              index * FEATURE_INDEX_LENGTH, FEATURE_INDEX_LENGTH
            ]

            index_data.unpack('n').first
          end
        end

        private

        def parse!
          @lookup_order, @required_feature_index, @count = read(6, 'nnn')
          @raw_feature_indices = io.read(count * FEATURE_INDEX_LENGTH)
          @length = 6 + @raw_feature_indices.length
        end

        def indices
          @indices ||= {}
        end
      end
    end
  end
end
