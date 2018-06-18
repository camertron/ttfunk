require 'stringio'

module TTFunk
  class UnresolvedPlaceholderError < StandardError
  end

  class MultiplePlaceholdersError < StandardError
  end

  class EncodedString
    def initialize
      yield self if block_given?
    end

    def <<(obj)
      case obj
      when String
        io << obj
      when Placeholder
        add_placeholder(obj, obj.position || io.pos, obj.relative_to)
        io << "\0" * obj.length
      when self.class
        # adjust placeholders to be relative to the entire encoded string
        obj.placeholders.each_pair do |_, placeholders|
          placeholders.each do |ph|
            add_placeholder(
              ph.dup,
              ph.relative? ? ph.position : ph.position + io.length,
              ph.relative? ? ph.relative_to + io.length : ph.relative_to
            )
          end
        end

        self << obj.unresolved_string
      end

      self
    end

    def align!(width = 4)
      if length % width > 0
        self << "\0" * (width - length % width)
      end

      self
    end

    def length
      io.length
    end

    def string
      remaining = placeholders.inject(0) do |sum, (_, ph)|
        sum + ph.size
      end

      unless remaining == 0
        raise UnresolvedPlaceholderError, 'string contains '\
          "#{remaining} unresolved placeholder(s)"
      end

      io.string
    end

    def bytes
      string.bytes
    end

    def unresolved_string
      io.string
    end

    def placeholders
      @placeholders ||= Hash.new { |h, k| h[k] = [] }
    end

    def resolve_placeholder(name, value)
      if placeholders[name].size > 1
        raise MultiplePlaceholdersError, 'More than one placeholder was found '\
          "for '#{name}'. Use #encode_each instead."
      end

      if (placeholder = placeholders[name].first)
        resolve(placeholder, value)
        placeholders[name].delete_at(0)
      end
    end

    def resolve_each(name)
      return to_enum(__method__, name) unless block_given?

      placeholders[name].each do |placeholder|
        resolve(placeholder, yield(placeholder))
      end

      placeholders.delete(name)
    end

    private

    def resolve(placeholder, value)
      last_pos = io.pos

      if placeholder.relative?
        io.seek(placeholder.relative_to + placeholder.position)
      else
        io.seek(placeholder.position)
      end

      io.write(value[0..placeholder.length])
    ensure
      io.seek(last_pos)
    end

    def add_placeholder(new_placeholder, pos = io.pos, relative_to = nil)
      new_placeholder.position = pos
      new_placeholder.relative_to = relative_to
      placeholders[new_placeholder.name] << new_placeholder
    end

    def io
      @io ||= StringIO.new.binmode
    end
  end
end
