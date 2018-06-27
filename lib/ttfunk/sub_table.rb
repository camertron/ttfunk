require_relative './reader'

module TTFunk
  class SubTable
    include Reader

    def self.underscored_name
      @underscored_name ||= name
        .split('::').last
        .gsub(/([a-z])([A-Z])/, '\\1_\\2')
        .downcase
    end

    attr_reader :file, :table_offset, :length

    def initialize(file, offset, length = nil)
      @file = file
      @table_offset = offset
      @length = length
      parse_from(@table_offset) { parse! }
    end

    def id
      @id ||= "#{self.class.underscored_name}_#{table_offset}"
    end

    def placeholder
      @placeholder ||= Placeholder.new(id, length: 2)
    end

    private

    def sum(enum)
      enum.inject(0) { |sum, element| sum + yield(element) }
    end
  end
end
