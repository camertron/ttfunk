# frozen_string_literal: true

module TTFunk
  class Min
    attr_reader :value

    def initialize(init_value = nil)
      @value = init_value
    end

    def <<(new_value)
      if value.nil? || new_value < value
        @value = new_value
      end
    end

    def value_or(default)
      return default if value.nil?

      value
    end
  end
end
