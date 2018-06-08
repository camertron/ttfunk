module TTFunk
  class Table
    class Cff < TTFunk::Table
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
      autoload :PrivateDict,      'ttfunk/table/cff/private_dict'

      TAG = 'CFF '.freeze # the extra space is important

      attr_reader :header, :name_index

      def tag
        TAG
      end

      def encode(_mapping)
        [header.encode, name_index.encode].join
      end

      private

      def parse!
        @header = Header.new(file, offset)
        @name_index = Index.new(file, @header.table_offset + @header.length)
      end
    end
  end
end
