# frozen_string_literal: true

module TTFunk
  class Sum
    attr_reader :value

    def initialize(init_value = 0)
      @value = init_value
    end

    def <<(operand)
      @value += operand
    end
  end
end
