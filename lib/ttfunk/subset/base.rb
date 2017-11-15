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
        encoder.encode(original_glyph_ids, cmap_table, options)
      end

      private

      def encoder
        @encoder ||= encoder_klass.new(original)
      end

      def encoder_klass
        original.cff.exists? ? OtfEncoder : TtfEncoder
      end

      def unicode_cmap
        @unicode_cmap ||= @original.cmap.unicode.first
      end
    end
  end
end
