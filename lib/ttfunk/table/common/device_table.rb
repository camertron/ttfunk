module TTFunk
  class Table
    module Common
      class DeviceTable < TTFunk::SubTable
        attr_reader :start_size, :end_size, :delta_format, :delta_values

        private

        def parse!
          @start_size, @end_size, @delta_format, delta_value = read(8, 'n4')

          bit_len = case delta_format
            when 1 then 2
            when 2 then 4
            else 8
          end

          num_elements = 16 / bit_len
          mask = (2 ** bit_len) - 1

          @delta_values = Array.new(num_elements) do |i|
            shift = (num_elements - i - 1) * bit_len
            BinUtils.twos_comp((delta_value >> shift) & mask, bit_len)
          end
        end
      end
    end
  end
end
