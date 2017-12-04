module TTFunk
  class OtfEncoder
    attr_reader :original

    def initialize(original)
      @original = original
    end

    def encode(original_glyph_ids, cmap_table, options = {})
    end
  end
end
