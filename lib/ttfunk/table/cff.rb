module TTFunk
  class Table
    class Cff < TTFunk::Table
      autoload :CffTable,   'ttfunk/table/cff/cff_table'
      autoload :Charset,    'ttfunk/table/cff/charset'
      autoload :Charstring, 'ttfunk/table/cff/charstring'
      autoload :Dict,       'ttfunk/table/cff/dict'
      autoload :Encoding,   'ttfunk/table/cff/encoding'
      autoload :FontDict,   'ttfunk/table/cff/font_dict'
      autoload :FontIndex,  'ttfunk/table/cff/font_index'
      autoload :Header,     'ttfunk/table/cff/header'
      autoload :Index,      'ttfunk/table/cff/index'
      autoload :Path,       'ttfunk/table/cff/path'
      autoload :SubrIndex,  'ttfunk/table/cff/subr_index'
      autoload :TopDict,    'ttfunk/table/cff/top_dict'
      autoload :TopIndex,   'ttfunk/table/cff/top_index'

      TAG = 'CFF '.freeze  # extra space is important

      attr_reader :header, :name_index, :top_index, :string_index
      attr_reader :global_subr_index

      def tag
        TAG
      end

      private

      def parse!
        @header = Header.new(file, offset)
        @name_index = Index.new(file, @header.table_offset + @header.length)
        @top_index = TopIndex.new(file, @name_index.table_offset + @name_index.length)
        @string_index = Index.new(file, @top_index.table_offset + @top_index.length)
        @global_subr_index = SubrIndex.new(file, @string_index.table_offset + @string_index.length)
      end
    end
  end
end
