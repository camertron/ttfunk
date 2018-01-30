require 'stringio'

module TTFunk
  class EncodedString
    def self.create
      new.tap { |enc_str| yield enc_str }
    end

    def <<(obj)
      case obj
        when String
          io << obj
        when Placeholder
          obj.position ||= io.pos
          placeholders[obj.category][obj.name] << obj
          io << "\0" * obj.length
        when self.class
          # adjust placeholders to be relative to the entire encoded string
          obj.placeholders.each_pair do |category, ph_hash|
            ph_hash.each_pair do |name, ph_arr|
              ph_arr.each do |ph|
                copied_ph = ph.dup

                if ph.relative?
                  copied_ph.relative_to += io.length
                else
                  copied_ph.position += io.length
                end

                placeholders[ph.category][ph.name] << copied_ph
              end
            end
          end

          io << obj.io.string
      end

      self
    end

    def write(value, pack_format)
      self << Array(value).pack(pack_format)
    end

    def write_f2dot14(num)
      self << BinUtils.pack_f2dot14(num)
    end

    def pos
      io.pos
    end

    def length
      io.length
    end

    alias_method :bytesize, :length

    def string
      io.string
    end

    def add_placeholder(category, name, position: nil, length: 1, relative_to: nil)
      placeholders[category][name] << Placeholder.new(
        category, name, position: position || io.pos, length: length, relative_to: relative_to
      )
    end

    # @TODO: refactor to combine logic with resolve_placeholders
    def resolve_each(category, name)
      last_pos = io.pos

      placeholders[category][name].each do |placeholder|
        start_pos, length = placeholders[category][name]

        value = yield placeholder

        if placeholder.relative?
          io.seek(placeholder.relative_to + placeholder.position)
        else
          io.seek(placeholder.position)
        end

        io.write(value[0..placeholder.length])
      end

      placeholders[category].delete(name)

      if placeholders[category].empty?
        placeholders.delete(category)
      end
    ensure
      io.seek(last_pos)
    end

    # @TODO: refactor to combine logic with resolve_each
    def resolve_placeholders(category, name, value)
      last_pos = io.pos

      placeholders[category][name].each do |placeholder|
        start_pos, length = placeholders[category][name]

        if placeholder.relative?
          io.seek(placeholder.relative_to + placeholder.position)
        else
          io.seek(placeholder.position)
        end

        io.write(value[0..placeholder.length])
      end

      placeholders[category].delete(name)

      if placeholders[category].empty?
        placeholders.delete(category)
      end
    ensure
      io.seek(last_pos)
    end

    def has_placeholders?(category, name)
      placeholders.include?(category) && placeholders[category].include?(name)
    end

    def io
      @io ||= StringIO.new.tap do |sio|
        sio.set_encoding(::Encoding::ASCII_8BIT)
      end
    end

    def placeholders_for(category, name)
      placeholders.fetch(category, {}).fetch(name, [])
    end

    def placeholders
      @placeholders ||= Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = [] } }
    end
  end
end
