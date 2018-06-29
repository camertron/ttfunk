module TTFunk
  class Table
    class Gpos
      class ValueTable < TTFunk::SubTable
        attr_reader :x_placement, :y_placement, :x_advance, :y_advance
        attr_reader :x_pla_device_offset, :y_pla_device_offset
        attr_reader :x_adv_device_offset, :y_adv_device_offset
        attr_reader :value_format, :lookup_table_offset

        def initialize(file, offset, value_format, lookup_table_offset)
          @value_format = BitField.new(value_format)
          @lookup_table_offset = lookup_table_offset
          super(file, offset)
        end

        def x_placement?
          value_format.on?(0)
        end

        def y_placement?
          value_format.on?(1)
        end

        def x_advance?
          value_format.on?(2)
        end

        def y_advance?
          value_format.on?(3)
        end

        def x_placement_device?
          value_format.on?(4)
        end

        def y_placement_device?
          value_format.on?(5)
        end

        def x_advance_device?
          value_format.on?(6)
        end

        def y_advance_device?
          value_format.on?(7)
        end

        def x_placement_device
          return unless x_placement_device?

          @x_placement_device ||= if file.variable?
            Common::VariationIndex.new(file, lookup_table_offset + x_pla_device_offset)
          else
            Common::DeviceTable.new(file, lookup_table_offset + x_pla_device_offset)
          end
        end

        def y_placement_device
          return unless y_placement_device?

          @y_placement_device ||= if file.variable?
            Common::VariationIndex.new(file, lookup_table_offset + y_pla_device_offset)
          else
            Common::DeviceTable.new(file, lookup_table_offset + y_pla_device_offset)
          end
        end

        def x_advance_device
          return unless x_advance_device?

          @x_advance_device ||= if file.variable?
            Common::VariationIndex.new(file, lookup_table_offset + x_adv_device_offset)
          else
            Common::DeviceTable.new(file, lookup_table_offset + x_adv_device_offset)
          end
        end

        def y_advance_device
          return unless y_advance_device?

          @y_advance_device ||= if file.variable?
            Common::VariationIndex.new(file, lookup_table_offset + y_adv_device_offset)
          else
            Common::DeviceTable.new(file, lookup_table_offset + y_adv_device_offset)
          end
        end

        def encode
          EncodedString.new do |result|
            result << [x_placement].pack('n') if x_placement?
            result << [y_placement].pack('n') if y_placement?
            result << [x_advance].pack('n') if x_advance?
            result << [y_advance].pack('n') if y_advance?

            # @TODO: figure out how to resolve these
            result << x_placement_device.placeholder if x_placement_device?
            result << y_placement_device.placeholder if y_placement_device?
            result << x_advance_device.placeholder if x_advance_device?
            result << y_advance_device.placeholder if y_advance_device?
          end
        end

        private

        def parse!
          @x_placement = read(2, 'n').first if x_placement?
          @y_placement = read(2, 'n').first if y_placement?
          @x_advance = read(2, 'n').first if x_advance?
          @y_advance = read(2, 'n').first if y_advance?
          @x_pla_device_offset = read(2, 'n').first if x_placement_device?
          @y_pla_device_offset = read(2, 'n').first if y_placement_device?
          @x_adv_device_offset = read(2, 'n').first if x_advance_device?
          @y_adv_device_offset = read(2, 'n').first if y_advance_device?

          @length = 2 * value_format.count_ones
        end
      end
    end
  end
end
