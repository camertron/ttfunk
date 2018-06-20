module TTFunk
  class Table
    class Layout < TTFunk::Table  # base class for Gsub and Gpos
      attr_reader :major_version, :minor_version
      attr_reader :script_list_offset, :feature_list_offset
      attr_reader :lookup_list_offset, :feature_variation_offset

      def self.encode(gsub, new2old_glyph)
        old2new_lookups = gsub.lookup_list.old2new_lookups_for(
          new2old_glyph.values
        )

        old2new_features = gsub.feature_list.old2new_features_for(
          old2new_lookups
        )

        EncodedString.new do |result|
          result << [gsub.major_version, gsub.minor_version].pack('nn')
          result << Placeholder.new("gsub_#{gsub.script_list.id}", length: 2)
          result << Placeholder.new("gsub_#{gsub.feature_list.id}", length: 2)
          result << Placeholder.new("gsub_#{gsub.lookup_list.id}", length: 2)

          result.resolve_placeholder("gsub_#{gsub.script_list.id}", [result.length].pack('n'))
          result << gsub.script_list.encode(old2new_features)

          result.resolve_placeholder("gsub_#{gsub.feature_list.id}", [result.length].pack('n'))
          result << gsub.feature_list.encode(old2new_lookups, old2new_features)

          result.resolve_placeholder("gsub_#{gsub.lookup_list.id}", [result.length].pack('n'))
          result << gsub.lookup_list.encode(new2old_glyph, old2new_lookups)
          gsub.lookup_list.finalize(result, old2new_lookups)

          # I can't find any examples of this in the wild...
          if gsub.feature_variation_list
            result.resolve_placeholder("gsub_#{gsub.feature_variation_list.id}", [result.length].pack('N'))
            result << gsub.feature_variation_list.encode
          end
        end.string
      end

      def script_list
        @script_list ||= Common::ScriptList.new(
          file, offset + script_list_offset
        )
      end

      def feature_list
        @feature_list ||= Common::FeatureList.new(
          file, offset + feature_list_offset
        )
      end

      def lookup_list
        @lookup_list ||= Common::LookupList.new(
          file, offset + lookup_list_offset, lookup_table
        )
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
