module TTFunk
  class Tag
    attr_reader :name, :position

    def initialize(name, pos)
      @name = name
      @position = pos
    end
  end
end
