# frozen_string_literal: true

require_relative './reader'

module TTFunk
  class SubTable
    class EOTError < StandardError
    end

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

    def read(*args)
      # if eot?
      #   raise EOTError, 'attempted to read past the end of the table'
      # end

      super
    end

    private

    def sum(enum)
      enum.inject(0) { |sum, element| sum + yield(element) }
    end

    # end of table
    def eot?
      # if length isn't set yet there's no way to know if we're at the end of
      # the table or not
      return false unless length

      io.pos > table_offset + length
    end
  end
end
