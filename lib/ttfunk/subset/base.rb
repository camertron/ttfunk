require_relative '../table/cmap'
require_relative '../table/glyf'
require_relative '../table/head'
require_relative '../table/hhea'
require_relative '../table/hmtx'
require_relative '../table/kern'
require_relative '../table/loca'
require_relative '../table/maxp'
require_relative '../table/name'
require_relative '../table/post'
require_relative '../table/simple'

module TTFunk
  module Subset
    class Base
      attr_reader :original

      def initialize(original)
        @original = original
      end

      def unicode?
        false
      end

      def to_unicode_map
        {}
      end

      def encode(options = {})
        cmap_table = new_cmap_table(options)
        glyphs = encoder.collect_glyphs(original, original_glyph_ids)

        old2new_glyph = cmap_table[:charmap].each_with_object(0 => 0) do |(_, ids), map|
          map[ids[:old]] = ids[:new]
        end

        next_glyph_id = cmap_table[:max_glyph_id]

        glyphs.keys.each do |old_id|
          unless old2new_glyph.key?(old_id)
            old2new_glyph[old_id] = next_glyph_id
            next_glyph_id += 1
          end
        end

        encoder.encode(original, old2new_glyph, cmap_table, options)
      end

      private

      def encoder
        original.cff.exists? ? OtfEncoder : TtfEncoder
      end

      def unicode_cmap
        @unicode_cmap ||= @original.cmap.unicode.first
      end
    end
  end
end
