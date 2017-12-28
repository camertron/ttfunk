module TTFunk
  class TtfEncoder
    attr_reader :original, :original_glyph_ids, :cmap_table, :options

    def initialize(original, original_glyph_ids, cmap_table, options = {})
      @original = original
      @original_glyph_ids = original_glyph_ids
      @cmap_table = cmap_table
      @options = options
    end

    def encode(options = {})
      # https://www.microsoft.com/typography/otspec/otff.htm#offsetTable
      search_range = 2 ** Math.log2(tables.length).ceil * 16
      entry_selector = Math.log2(2 ** Math.log2(tables.length).ceil).to_i
      range_shift = tables.length * 16 - search_range
      range_shift = 0 if range_shift < 0

      newfont = [
        original.directory.sfnt_version,
        tables.length,
        search_range,
        entry_selector,
        range_shift
      ].pack('Nn*')

      directory_size = tables.length * 16
      offset = newfont.length + directory_size

      table_data = ''
      head_offset = nil

      # tables are supposed to be listed in ascending order
      tables.keys.sort.each do |tag|
        data = tables[tag]
        byte_align!(data)
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

      byte_align!(newfont)
      sum = checksum(newfont)
      adjustment = 0xB1B0AFBA - sum
      newfont[head_offset + 8, 4] = [adjustment].pack('N')

      newfont
    end

    private

    def byte_align!(data)
      data << "\0" * (4 - data.length % 4) unless data.length % 4 == 0
    end

    def finalize(newfont)
      newfont
    end

    # "mandatory" tables. Every font should ("should") have these, including
    # the cmap table (encoded above).

    def glyf_table
      @glyf_table ||= if original.directory.tables.include?('glyf')
        TTFunk::Table::Glyf.encode(glyphs, new2old_glyph, old2new_glyph)
      else
        {}
      end
    end

    def loca_table
      @loca_table ||= if original.directory.tables.include?('loca')
        TTFunk::Table::Loca.encode(glyf_table[:offsets])
      else
        {}
      end
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
      @os2_table ||= original.os2.raw
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
        'cvt ' => cvt_table
      }.reject { |_tag, table| table.nil? }
    end

    def old2new_glyph
      @old2new_glyph ||= begin
        old2new = cmap_table[:charmap].each_with_object(0 => 0) do |(_, ids), map|
          map[ids[:old]] = ids[:new]
        end

        next_glyph_id = cmap_table[:max_glyph_id]

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
      @glyphs ||= collect_glyphs(original_glyph_ids)
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
      data = data.respond_to?(:string) ? data.string : data
      data.unpack('N*').reduce(0, :+) & 0xFFFF_FFFF
    end
  end
end
