require 'bigdecimal'
require 'bigdecimal/util'  # for Float#to_d

module TTFunk
  class Real
    attr_reader :base, :exponent

    def initialize(base, exponent)
      @base = base
      @exponent = exponent
    end

    def +(other)
      new_base = (other.base * base_adjustment_factor(other)) + base
      self.class.new(new_base, exponent)
    end

    def -(other)
      new_base = (other.base * base_adjustment_factor(other)) - base
      self.class.new(new_base, exponent)
    end

    def *(other)
      self.class.new(base * other.base, exponent + other.exponent)
    end

    def /(other)
      other_base = base_from(other)
      other_exponent = exponent_from(other)
      self.class.new(base / other_base, exponent - other_exponent)
    end

    def to_f
      base.to_f * 10 ** exponent
    end

    def to_d
      base.to_d * 10 ** exponent
    end

    def to_s
      to_d.to_s
    end

    private

    def base_from(other)
      case other
        when Float, Integer, BigDecimal
          other
        when self.class
          other.base
      end
    end

    def exponent_from(other)
      case other
        when Float, Integer, BigDecimal
          0
        else
          other.exponent
      end
    end

    def exponent_difference(other)
      other.exponent - exponent
    end

    def base_adjustment_factor(other)
      10 ** exponent_difference(other)
    end
  end
end
