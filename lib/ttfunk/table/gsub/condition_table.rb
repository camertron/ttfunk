module TTFunk
  class Table
    class Gsub
      class ConditionTable < TTFunk::SubTable
        attr_reader :format, :axis_index
        attr_reader :filter_range_min_value, :filter_range_max_value

        def encode
          EncodedString.create do |result|
            result.write([format, axis_index], 'nn')
            result.write_f2dot14(filter_range_min_value)
            result.write_f2dot14(filter_range_max_value)
          end
        end

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
