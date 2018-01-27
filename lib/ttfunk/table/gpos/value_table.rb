module TTFunk
  class Table
    class Gpos
      class ValueTable
        FORMAT = 'nnnnnnnn'

        def self.create_sequence(io, count)
          Sequence.from(io, count, FORMAT) { |*args| new(*args) }
        end

        attr_reader :x_placement, :y_placement, :x_advance, :y_advance
        attr_reader :x_pla_device_offset, :y_pla_device_offset
        attr_reader :x_adv_device_offset, :y_adv_device_offset
        attr_reader :length

        def initialize(*args)
          @x_placement, @y_placement, @x_advance, @y_advance
            @x_pla_device_offset, @y_pla_device_offset
            @x_adv_device_offset, @y_adv_device_offset = args

          @length = 16
        end
      end
    end
  end
end
