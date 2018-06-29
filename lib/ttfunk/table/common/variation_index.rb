module TTFunk
  class Table
    module Common
      class VariationIndex < TTFunk::SubTable
        attr_reader :delta_set_outer_index, :delta_set_inner_index
        attr_reader :delta_format

        def encode
          EncodedString.new do |result|
            result << [delta_set_outer_index, delta_set_inner_index].pack('n*')
            result << [delta_format].pack('n')
          end
        end

        private

        def parse!
          @delta_set_outer_index, @delta_set_inner_index,
            @delta_format = read(6, 'n*')
        end
      end
    end
  end
end
