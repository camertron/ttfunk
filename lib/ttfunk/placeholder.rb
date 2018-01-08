module TTFunk
  class Placeholder
    attr_reader :category, :name, :length

    def initialize(category, name, length)
      @category = category
      @name = name
      @length = length
    end
  end
end
