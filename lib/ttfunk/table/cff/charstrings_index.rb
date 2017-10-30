module TTFunk
  class Table
    class Cff < TTFunk::Table
      class CharstringsIndex < TTFunk::Table::Cff::Index
        attr_reader :top_dict

        def initialize(top_dict, file, offset, length = nil)
          super(file, offset, length)
          @top_dict = top_dict
        end

        private

        def parse!
        end

        def type
          top_dict.charstring_type
        end
      end
    end
  end
end
