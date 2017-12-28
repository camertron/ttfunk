module TTFunk
  class Table
    class Cff < TTFunk::Table
      autoload :CffTable,         'ttfunk/table/cff/cff_table'
      autoload :Charset,          'ttfunk/table/cff/charset'
      autoload :Charstring,       'ttfunk/table/cff/charstring'
      autoload :CharstringsIndex, 'ttfunk/table/cff/charstrings_index'
      autoload :Dict,             'ttfunk/table/cff/dict'
      autoload :Encoding,         'ttfunk/table/cff/encoding'
      autoload :FdSelector,       'ttfunk/table/cff/fd_selector'
      autoload :FontDict,         'ttfunk/table/cff/font_dict'
      autoload :FontIndex,        'ttfunk/table/cff/font_index'
      autoload :Header,           'ttfunk/table/cff/header'
      autoload :Index,            'ttfunk/table/cff/index'
      autoload :Path,             'ttfunk/table/cff/path'
      autoload :Predefined,       'ttfunk/table/cff/predefined'
      autoload :PrivateDict,      'ttfunk/table/cff/private_dict'
      autoload :SubrIndex,        'ttfunk/table/cff/subr_index'
      autoload :TopDict,          'ttfunk/table/cff/top_dict'
      autoload :TopIndex,         'ttfunk/table/cff/top_index'

      TAG = 'CFF '.freeze  # extra space is important

      attr_reader :header, :name_index, :top_index, :string_index
      attr_reader :global_subr_index

      def tag
        TAG
      end

      def encode
        result = EncodedString.new.tap do |result|
          result << header.encode
          result << name_index.encode
          result << top_index.encode { |top_dict| top_dict.encode }
          result << string_index.encode
          result << global_subr_index.encode
        end

        top_index[0].finalize(result)
        result.string
      end

      private

      def parse!
        @header = Header.new(file, offset)
        @name_index = Index.new(file, @header.table_offset + @header.length)
        @top_index = TopIndex.new(self, file, @name_index.table_offset + @name_index.length)
        @string_index = Index.new(file, @top_index.table_offset + @top_index.length)
        @global_subr_index = SubrIndex.new(file, @string_index.table_offset + @string_index.length)
      end
    end
  end
end
