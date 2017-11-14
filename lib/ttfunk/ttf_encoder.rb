module TTFunk
  class TtfEncoder
    class << self
      def encode(original, old2new_glyph, cmap_table, options = {})
        new2old_glyph = old2new_glyph.invert

        # "mandatory" tables. Every font should ("should") have these, including
        # the cmap table (encoded above).
        glyf_table = TTFunk::Table::Glyf.encode(
          glyphs, new2old_glyph, old2new_glyph
        )
        loca_table = TTFunk::Table::Loca.encode(glyf_table[:offsets])
        hmtx_table = TTFunk::Table::Hmtx.encode(
          original.horizontal_metrics, new2old_glyph
        )
        hhea_table = TTFunk::Table::Hhea.encode(
          original.horizontal_header, hmtx_table
        )
        maxp_table = TTFunk::Table::Maxp.encode(
          original.maximum_profile, old2new_glyph
        )
        post_table = TTFunk::Table::Post.encode(
          original.postscript, new2old_glyph
        )
        name_table = TTFunk::Table::Name.encode(
          original.name, glyf_table[:table]
        )
        head_table = TTFunk::Table::Head.encode(
          original.header, loca_table
        )

        # "optional" tables. Fonts may omit these if they do not need them.
        # Because they apply globally, we can simply copy them over, without
        # modification, if they exist.
        os2_table  = original.os2.raw
        cvt_table  = TTFunk::Table::Simple.new(original, 'cvt ').raw
        fpgm_table = TTFunk::Table::Simple.new(original, 'fpgm').raw
        prep_table = TTFunk::Table::Simple.new(original, 'prep').raw

        # for PDF's, the kerning info is all included in the PDF as the text is
        # drawn. Thus, the PDF readers do not actually use the kerning info in
        # embedded fonts. If the library is used for something else, the
        # generated subfont may need a kerning table... in that case, you need
        # to opt into it.
        if options[:kerning]
          kern_table =
            TTFunk::Table::Kern.encode(original.kerning, old2new_glyph)
        end

        tables = { 'cmap' => cmap_table[:table],
                   'glyf' => glyf_table[:table],
                   'loca' => loca_table[:table],
                   'kern' => kern_table,
                   'hmtx' => hmtx_table[:table],
                   'hhea' => hhea_table,
                   'maxp' => maxp_table,
                   'OS/2' => os2_table,
                   'post' => post_table,
                   'name' => name_table,
                   'head' => head_table,
                   'prep' => prep_table,
                   'fpgm' => fpgm_table,
                   'cvt ' => cvt_table }

        tables.delete_if { |_tag, table| table.nil? }

        search_range = (Math.log(tables.length) / Math.log(2)).to_i * 16
        entry_selector = (Math.log(search_range) / Math.log(2)).to_i
        range_shift = tables.length * 16 - search_range

        newfont = [
          original.directory.scaler_type,
          tables.length,
          search_range,
          entry_selector,
          range_shift
        ].pack('Nn*')

        directory_size = tables.length * 16
        offset = newfont.length + directory_size

        table_data = ''
        head_offset = nil
        tables.each do |tag, data|
          newfont << [tag, checksum(data), offset, data.length].pack('A4N*')
          table_data << data
          head_offset = offset if tag == 'head'
          offset += data.length
          while offset % 4 != 0
            offset += 1
            table_data << "\0"
          end
        end

        newfont << table_data
        sum = checksum(newfont)
        adjustment = 0xB1B0AFBA - sum
        newfont[head_offset + 8, 4] = [adjustment].pack('N')

        newfont
      end

      def collect_glyphs(original, glyph_ids)
        glyphs = glyph_ids.each_with_object({}) do |id, h|
          h[id] = original.glyph_outlines.for(id)
        end

        additional_ids = glyphs.values
          .select { |g| g && g.compound? }
          .map(&:glyph_ids)
          .flatten

        glyphs.update(collect_glyphs(additional_ids)) if additional_ids.any?

        glyphs
      end

      private

      def checksum(data)
        data += "\0" * (4 - data.length % 4) unless data.length % 4 == 0
        data.unpack('N*').reduce(0, :+) & 0xFFFF_FFFF
      end
    end
  end
end
