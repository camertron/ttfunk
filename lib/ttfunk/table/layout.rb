module TTFunk
  class Table
    class Layout < TTFunk::Table  # base class for Gsub and Gpos
      attr_reader :major_version, :minor_version
      attr_reader :script_list_offset, :feature_list_offset
      attr_reader :lookup_list_offset, :feature_variation_offset

      def self.encode(gsub)
        EncodedString.create do |result|
          result.write([gsub.major_version, gsub.minor_version], 'nn')
          result.add_placeholder(:gsub, gsub.script_list.id, position: result.length, length: 2)
          result << "\0\0"
          result.add_placeholder(:gsub, gsub.feature_list.id, position: result.length, length: 2)
          result << "\0\0"
          result.add_placeholder(:gsub, gsub.lookup_list.id, position: result.length, length: 2)
          result << "\0\0"

          result.resolve_placeholders(:gsub, gsub.script_list.id, [result.length].pack('n'))
          result << gsub.script_list.encode

          result.resolve_placeholders(:gsub, gsub.feature_list.id, [result.length].pack('n'))
          result << gsub.feature_list.encode

          result.resolve_placeholders(:gsub, gsub.lookup_list.id, [result.length].pack('n'))
          result << gsub.lookup_list.encode
          gsub.lookup_list.finalize(result)

          if gsub.feature_variation_list
            result.resolve_placeholders(:gsub, gsub.feature_variation_list.id, [result.length].pack('N'))
            result << gsub.feature_variation_list.encode
          end
        end.string
      end

      def script_list
        @script_list ||= Common::ScriptList.new(file, offset + script_list_offset)
      end

      def feature_list
        @feature_list ||= Common::FeatureList.new(file, offset + feature_list_offset)
      end

      def lookup_list
        @lookup_list ||= Common::LookupList.new(file, offset + lookup_list_offset, lookup_table)
      end

      def feature_variation_list
        @feature_variation_list ||= if feature_variation_offset
          Common::FeatureVariationList.new(
            file, offset + feature_variations_offset
          )
        end
      end

      def max_context
        @max_context ||= feature_list.tables.flat_map do |feature|
          feature.lookup_indices.flat_map do |lookup_index|
            lookup_list.tables[lookup_index].sub_tables.map do |sub_table|
              sub_table.max_context
            end
          end
        end.max
      end

      private

      def parse!
        @major_version, @minor_version, @script_list_offset,
          @feature_list_offset, @lookup_list_offset = read(10, 'n5')

        if minor_version == 1
          @feature_variations_offset = read(4, 'N')
        end
      end
    end
  end
end
