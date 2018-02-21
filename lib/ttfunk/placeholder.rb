module TTFunk
  class Placeholder
    attr_accessor :position, :relative_to
    attr_reader :category, :name, :length

    def initialize(category, name, position: nil, length: 1, relative_to: nil)
      @category = category
      @name = name
      @length = length
      @position = position
      @relative_to = relative_to
    end

    def relative?
      !!relative_to
    end
  end
end
