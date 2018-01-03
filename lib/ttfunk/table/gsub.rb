require_relative '../table'

module TTFunk
  class Table
    class Gsub < TTFunk::Table
      TAG = 'GSUB'.freeze

      attr_reader :major_version, :minor_version
      attr_reader :script_list_offset, :feature_list_offset
      attr_reader :lookup_list_offset, :feature_variation_offset

      def self.encode
        # @TODO
        raw
      end

      def tag
        TAG
      end

      def script_list
        @script_list ||= Common::ScriptList.new(file, offset + script_list_offset)
      end

      def feature_list
        @feature_list ||= Common::FeatureList.new(file, offset + feature_list_offset)
      end

      def lookup_list
        @lookup_list ||= Common::LookupList.new(file, offset + lookup_list_offset)
      end

      def feature_variation_list
        @feature_variation_list ||= if feature_variation_offset
          Common::FeatureVariationList.new(
            file, offset + feature_variations_offset
          )
        end
      end

      private

      def parse!
        @major_version, @minor_version, @script_list_offset,
          @feature_list_offset, @lookup_list_offset = read(10, 'n*')

        if minor_version == 1
          @feature_variations_offset = read(4, 'N')
        end
      end
    end
  end
end

require_relative './common'
