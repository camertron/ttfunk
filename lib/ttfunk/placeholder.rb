module TTFunk
  class Placeholder
    attr_accessor :position, :relative_to
    attr_reader :name, :length

    def initialize(name, length: 1, relative_to: nil)
      @name = name
      @length = length
      @relative_to = relative_to
    end

    def relative?
      !relative_to.nil?
    end
  end
end
