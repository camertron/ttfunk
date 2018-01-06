module TTFunk
  class Table
    module Common
      class ConditionTable < TTFunk::SubTable
        attr_reader :format, :axis_index
        attr_reader :filter_range_min_value, :filter_range_max_value

        private

        def parse!
          @format, @axis_index = read(4, 'nn')
          @filter_range_min_value, @filter_range_max_value = read_f2dot14(2)
          @length = 8
        end
      end
    end
  end
end
