module TTFunk
  class OtfEncoder < TtfEncoder
    private

    # @TODO pass desired glyphs
    def cff_table
      @cff_table ||= original.cff.encode
    end

    def dsig_table
      @dsig_table ||= TTFunk::Table::Simple.new(original, 'DSIG').raw
    end

    def tables
      @tables ||= super.tap do |tb|
        tb['DSIG'] = dsig_table
        tb['CFF '] = cff_table
      end
    end

    def collect_glyphs(glyph_ids)
      # CFF top indexes are supposed to contain only one font, although they're
      # capable of supporting many (no idea why this is true, maybe for CFF v2??)
      glyph_ids.each_with_object({}) do |id, h|
        h[id] = original.cff.top_index[0].charstrings_index[id]
      end
    end
  end
end
