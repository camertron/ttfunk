module TTFunk
  class OtfEncoder < TtfEncoder
    private

    # CFF fonts don't maintain a glyf table, all glyph information is stored
    # in the charstrings index. Return an empty hash here to indicate a glyf
    # table should not be encoded.
    def glyf_table
      @glyf_table ||= {}
    end

    # Since CFF fonts don't maintain a glyf table, they also don't maintain
    # a loca table. Return an empty hash here to indicate a loca table
    # shouldn't be encoded.
    def loca_table
      @loca_table ||= {}
    end

    def base_table
      @base_table ||= TTFunk::Table::Simple.new(original, 'BASE').raw
    end

    # @TODO pass desired glyphs
    def cff_table
      @cff_table ||= original.cff.encode
    end

    # @TODO sign fonts correctly. But how??
    def dsig_table
      @dsig_table ||= TTFunk::Table::Simple.new(original, 'DSIG').raw
    end

    def vorg_table
      @vorg_table ||= original.vertical_origins.encode
    end

    def tables
      @tables ||= super.tap do |tb|
        tb['BASE'] = base_table
        tb['DSIG'] = dsig_table
        tb['VORG'] = vorg_table
        tb['CFF '] = cff_table
      end
    end

    def collect_glyphs(glyph_ids)
      # CFF top indexes are supposed to contain only one font, although they're
      # capable of supporting many (no idea why this is true, maybe for CFF v2??).
      # Anyway it's cool to do top_index[0], don't worry about it.
      glyph_ids.each_with_object({}) do |id, h|
        h[id] = original.cff.top_index[0].charstrings_index[id]
      end
    end
  end
end
