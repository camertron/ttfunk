require_relative './reader'

module TTFunk
  class SubTable
    include Reader

    attr_reader :file, :table_offset

    # set by parse! in derived classes
    attr_reader :length

    def self.underscored_name
      @underscored_name ||= name
        .split('::').last
        .gsub(/([a-z])([A-Z])/, '\\1_\\2')
        .downcase
    end

    def initialize(file, offset, length = nil)
      @file = file
      @table_offset = offset
      # if length is nil, it should be set to an actual value in derived classes
      @length = length
      parse_from(@table_offset) { parse! }
    end

    def id
      @id ||= "#{self.class.underscored_name}_#{table_offset}"
    end

    private

    def ph(category, name, length)
      Placeholder.new(category, name, length)
    end
  end
end
