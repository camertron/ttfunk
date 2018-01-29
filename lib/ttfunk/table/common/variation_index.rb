module TTFunk
  class Table
    module Common
      class VariationIndex < TTFunk::SubTable
        attr_reader :delta_set_outer_index, :delta_set_inner_index
        attr_reader :delta_format

        private

        def parse!
          @delta_set_outer_index, @delta_set_inner_index,
            @delta_format = read(6, 'nnn')
        end
      end
    end
  end
end
