module TTFunk
  class TtfEncoder
    OPTIMAL_TABLE_ORDER = %w(
      head hhea maxp OS/2 hmtx LTSH VDMX hdmx cmap fpgm
      prep cvt loca glyfkern name post gasp PCLT
    )

    attr_reader :original, :subset, :options

    def initialize(original, subset, options = {})
      @original = original
      @subset = subset
      @options = options
    end

    def encode
      # https://www.microsoft.com/typography/otspec/otff.htm#offsetTable
      search_range = 2 ** Math.log2(tables.length).floor * 16
      entry_selector = Math.log2(2 ** Math.log2(tables.length).floor).to_i
      range_shift = tables.length * 16 - search_range
      range_shift = 0 if range_shift < 0

      newfont = EncodedString.new

      newfont << [
        original.directory.sfnt_version,
        tables.length,
        search_range,
        entry_selector,
        range_shift
      ].pack('Nn*')

      table_data = ''
      head_offset = nil

      # Tables are supposed to be listed in ascending order whereas there is a
      # known optimal order for table data.
      tables.keys.sort.each do |tag|
        data = tables[tag]
        newfont << [tag, checksum(data)].pack('A4N')
        newfont.add_placeholder(:tables, tag, position: newfont.length, length: 4)
        newfont << [0, data.length].pack('N*')  # zero is fake offset to data
      end

      offset = newfont.length

      optimal_table_order.each do |optimal_tag|
        head_offset = offset if optimal_tag == 'head'

        if tables.include?(optimal_tag)
          newfont.resolve_placeholders(:tables, optimal_tag, [offset].pack('N'))
          data = tables[optimal_tag]
          newfont << data

          offset += data.length

          # align to 4 bytes
          newfont << "\0" * (offset % 4)
          offset += offset % 4
        end
      end

      newfont = newfont.string

      sum = checksum(newfont)
      adjustment = 0xB1B0AFBA - sum
      newfont[head_offset + 8, 4] = [adjustment].pack('N')

      newfont
    end

    private

    def optimal_table_order
      OPTIMAL_TABLE_ORDER + (tables.keys - ['DSIG'] - OPTIMAL_TABLE_ORDER) + ['DSIG']
    end

    def finalize(newfont)
      newfont
    end

    # "mandatory" tables. Every font should ("should") have these

    def cmap_table
      @cmap_table ||= subset.new_cmap_table
    end

    def glyf_table
      @glyf_table ||= TTFunk::Table::Glyf.encode(
        glyphs, new2old_glyph, old2new_glyph
      )
    end

    def loca_table
      @loca_table ||= TTFunk::Table::Loca.encode(
        glyf_table[:offsets]
      )
    end

    def hmtx_table
      @hmtx_table ||= TTFunk::Table::Hmtx.encode(
        original.horizontal_metrics, new2old_glyph
      )
    end

    def hhea_table
      @hhea_table = TTFunk::Table::Hhea.encode(
        original.horizontal_header, hmtx_table
      )
    end

    def maxp_table
      @maxp_table ||= TTFunk::Table::Maxp.encode(
        original.maximum_profile, old2new_glyph
      )
    end

    def post_table
      @post_table ||= TTFunk::Table::Post.encode(
        original.postscript, new2old_glyph
      )
    end

    def name_table
      @name_table ||= TTFunk::Table::Name.encode(
        original.name, glyf_table.fetch(:table, '')
      )
    end

    def head_table
      @head_table ||= TTFunk::Table::Head.encode(
        original.header, loca_table
      )
    end

    # "optional" tables. Fonts may omit these if they do not need them.
    # Because they apply globally, we can simply copy them over, without
    # modification, if they exist.

    def os2_table
      # @os2_table ||= original.os2.raw
      @os2_table ||= TTFunk::Table::OS2.encode(original.os2, subset)
    end

    def cvt_table
      @cvt_table ||= TTFunk::Table::Simple.new(original, 'cvt ').raw
    end

    def fpgm_table
      @fpgm_table ||= TTFunk::Table::Simple.new(original, 'fpgm').raw
    end

    def prep_table
      @prep_table ||= TTFunk::Table::Simple.new(original, 'prep').raw
    end

    def kern_table
      # for PDF's, the kerning info is all included in the PDF as the text is
      # drawn. Thus, the PDF readers do not actually use the kerning info in
      # embedded fonts. If the library is used for something else, the
      # generated subfont may need a kerning table... in that case, you need
      # to opt into it.
      if options[:kerning]
        @kern_table ||= TTFunk::Table::Kern.encode(
          original.kerning, old2new_glyph
        )
      end
    end

    def gpos_table
      @gpos_table ||= TTFunk::Table::Gpos.encode(original.glyph_positioning)
    end

    def gsub_table
      @gsub_table ||= TTFunk::Table::Gsub.encode(original.glyph_substitution)
    end

    def tables
      @tables ||= {
        'cmap' => cmap_table[:table],
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
        'cvt ' => cvt_table,
        'GPOS' => gpos_table,
        'GSUB' => gsub_table
      }.reject { |_tag, table| table.nil? }
    end

    def old2new_glyph
      @old2new_glyph ||= begin
        old2new = cmap_table[:charmap].each_with_object(0 => 0) do |(_, ids), map|
          map[ids[:old]] = ids[:new]
        end

        next_glyph_id = cmap_table[:max_glyph_id]

        # Add glyph mappings that were not part of the original subset, i.e. won't
        # have been included in the old cmap. This begs the question however: how
        # do these new glyphs get added to the cmap? It appears they never do since
        # the new cmap table has already been encoded at this point. So, that's
        # probably a bug. Moreover, the value of cmap_table[:charmap] contains these
        # new glyphs as having old and new IDs of 0 (i.e. undefined), which
        # unfortunately means the code above that constructs the old2new hash
        # overwrites them. By the time we get to the code below, the new glyphs are
        # all but a forgotten memory. That's probably fine since this library was
        # meant to generate subsets of existing fonts (I'm not aware of any use
        # cases that require the ability to add new glyphs to a font). Let's leave
        # in the code below for now. It's innocuous because it will never actually
        # do anything. If we want to enable adding new glyphs to fonts, it may come
        # in handy. I would advocate moving it to the TTFunk::Subset classes however
        # (specifically the new_cmap_table method) since, as I mentioned above, the
        # cmap table has already been encoded at this point. The move will also
        # obviate the need for Cmap#encode to return a max_glyph_id, since all the
        # glyph ids will have already been assigned to their respective characters
        # during the construction of the cmap.
        glyphs.keys.each do |old_id|
          unless old2new.key?(old_id)
            old2new[old_id] = next_glyph_id
            next_glyph_id += 1
          end
        end

        old2new
      end
    end

    def new2old_glyph
      @new2old_glyph ||= old2new_glyph.invert
    end

    def glyphs
      @glyphs ||= collect_glyphs(subset.original_glyph_ids)
    end

    def collect_glyphs(glyph_ids)
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

    def checksum(data)
      # For some reason, 32-bit alignment is only important when checksumming.
      # Microsoft's FontValidator tool will complain if the table data itself
      # is padded with null (i.e. \0) alignment bytes (reports the table is
      # too long), but will also complain if the checksum is calculated with
      # unaligned data. I guess the solution is to calculate the checksum on
      # aligned data but encode the table unaligned. Weird but it works.
      data = data.respond_to?(:string) ? data.string : data
      align(data).unpack('N*').reduce(0, :+) & 0xFFFF_FFFF
    end

    def align(data)
      return data if data.length % 4 == 0
      data + "\0" * (4 - data.length % 4)
    end
  end
end
