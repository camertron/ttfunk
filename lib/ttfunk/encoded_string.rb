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
          add_placeholder(obj.category, obj.name, length, obj.length)
          io << "\0" * obj.length
        when self.class
          # adjust placeholders to be relative to the entire encoded string
          obj.placeholders.each_pair do |category, ph_hash|
            ph_hash.each_pair do |name, props|
              placeholders[category][name] = [props[0] + io.length, props[1]]
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

    def add_placeholder(category, name, position = io.pos, length = 1)
      placeholders[category][name] = [position, length]
    end

    def resolve_placeholder(category, name, value)
      last_pos = io.pos
      start_pos, length = placeholders[category][name]
      io.seek(start_pos)
      io.write(value[0..length])
      placeholders[category].delete(name)

      if placeholders[category].empty?
        placeholders.delete(category)
      end
    ensure
      io.seek(last_pos)
    end

    def io
      @io ||= StringIO.new.tap do |sio|
        sio.set_encoding(::Encoding::ASCII_8BIT)
      end
    end

    def placeholders
      @placeholders ||= Hash.new { |h, k| h[k] = {} }
    end
  end
end
