require 'set'

require_relative 'base'
require_relative '../encoding/mac_roman'

module TTFunk
  module Subset
    class MacRoman < Base
      def initialize(original)
        super
        @subset = Array.new(256)
      end

      def code_page
        :mac_roman
      end

      def to_unicode_map
        Encoding::MacRoman::TO_UNICODE
      end

      def use(character)
        @subset[Encoding::MacRoman::FROM_UNICODE[character]] = character
      end

      def covers?(character)
        Encoding::MacRoman.covers?(character)
      end

      def includes?(character)
        code = Encoding::MacRoman::FROM_UNICODE[character]
        code && @subset[code]
      end

      def from_unicode(character)
        Encoding::MacRoman::FROM_UNICODE[character]
      end

      def new_cmap_table
        @new_cmap_table ||= begin
          mapping = {}

          @subset.each_with_index do |unicode, roman|
            mapping[roman] = unicode_cmap[unicode] if roman
          end

          TTFunk::Table::Cmap.encode(mapping, :mac_roman)
        end
      end

      def original_glyph_ids
        ([0] + @subset.map { |unicode| unicode && unicode_cmap[unicode] })
          .compact.uniq.sort
      end
    end
  end
end
