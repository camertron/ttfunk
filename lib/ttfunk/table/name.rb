require_relative '../table'
require 'digest/sha1'

module TTFunk
  class Table
    class Name < Table
      POST_SCRIPT_NAME_ID = 6

      class NameString
        attr_reader :text, :platform_id, :encoding_id, :language_id, :name_id

        def initialize(text, platform_id, encoding_id, language_id, name_id)
          @text = text
          @platform_id = platform_id
          @encoding_id = encoding_id
          @language_id = language_id
          @name_id = name_id
        end

        def strip_extended
          stripped = text.gsub(/[\x00-\x19\x80-\xff]/n, '')
          stripped = '[not-postscript]' if stripped.empty?
          stripped
        end

        def length
          text.length
        end
      end

      attr_reader :entries
      attr_reader :strings

      attr_reader :copyright
      attr_reader :font_family
      attr_reader :font_subfamily
      attr_reader :unique_subfamily
      attr_reader :font_name
      attr_reader :version
      attr_reader :trademark
      attr_reader :manufacturer
      attr_reader :designer
      attr_reader :description
      attr_reader :vendor_url
      attr_reader :designer_url
      attr_reader :license
      attr_reader :license_url
      attr_reader :preferred_family
      attr_reader :preferred_subfamily
      attr_reader :compatible_full
      attr_reader :sample_text

      class << self
        def encode(names, key = '')
          tag = Digest::SHA1.hexdigest(key)[0, 6]

          strings = names.strings.reject { |str| str.name_id == POST_SCRIPT_NAME_ID }
          strings << NameString.new(
            "#{tag}+#{names.postscript_name}", 1, 0, 0, POST_SCRIPT_NAME_ID
          )

          table = [0, strings.size, 6 + 12 * strings.size].pack('n*')
          strtable = ''

          sort_strings(strings).each do |string|
            table << [
              string.platform_id, string.encoding_id, string.language_id, string.name_id,
              string.length, strtable.length
            ].pack('n*')
            strtable << string.text
          end

          table << strtable
        end
        items = items.sort_by do |id, string|
          [string.platform_id, string.encoding_id, string.language_id, id]
        end
        items.each do |id, string|
          table << [
            string.platform_id, string.encoding_id, string.language_id, id,
            string.length, strtable.length
          ].pack('n*')
          strtable << string
        end

        private

        def sort_strings(strings)
          strings.sort do |a, b|
            if a.platform_id == b.platform_id
              if a.encoding_id == b.encoding_id
                if a.language_id == b.language_id
                  a.name_id <=> b.name_id
                else
                  a.language_id <=> b.language_id
                end
              else
                a.encoding_id <=> b.encoding_id
              end
            else
              a.platform_id <=> b.platform_id
            end
          end
        end
      end

      def postscript_name
        return @postscript_name if @postscript_name
        font_family.first || 'unnamed'
      end

      private

      def parse!
        count, string_offset = read(6, 'x2n*')
        entries = []

        count.times do
          platform, encoding, language, name_id, length, start_offset =
            read(12, 'n*')

          entries << {
            platform_id: platform,
            encoding_id: encoding,
            language_id: language,
            name_id: name_id,
            length: length,
            offset: offset + string_offset + start_offset,
            text: nil
          }
        end

        @strings = []
        strings_by_name_id = {}

        entries.each do |entry|
          io.pos = entry[:offset]
          text = io.read(entry[:length])

          string = NameString.new(
            text,
            entry[:platform_id],
            entry[:encoding_id],
            entry[:language_id],
            entry[:name_id]
          )

          @strings << string
          strings_by_name_id[string.name_id] ||= []
          strings_by_name_id[string.name_id] << string
        end

        @copyright = strings_by_name_id[0]
        @font_family = strings_by_name_id[1]
        @font_subfamily = strings_by_name_id[2]
        @unique_subfamily = strings_by_name_id[3]
        @font_name = strings_by_name_id[4]
        @version = strings_by_name_id[5]
        # should only be ONE postscript name
        @postscript_name = strings_by_name_id[POST_SCRIPT_NAME_ID]  # 6
          .first.strip_extended
        @trademark = strings_by_name_id[7]
        @manufacturer = strings_by_name_id[8]
        @designer = strings_by_name_id[9]
        @description = strings_by_name_id[10]
        @vendor_url = strings_by_name_id[11]
        @designer_url = strings_by_name_id[12]
        @license = strings_by_name_id[13]
        @license_url = strings_by_name_id[14]
        @preferred_family = strings_by_name_id[16]
        @preferred_subfamily = strings_by_name_id[17]
        @compatible_full = strings_by_name_id[18]
        @sample_text = strings_by_name_id[19]
      end
    end
  end
end
