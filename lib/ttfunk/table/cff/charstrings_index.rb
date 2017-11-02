module TTFunk
  class Table
    class Cff < TTFunk::Table
      class CharstringsIndex < TTFunk::Table::Cff::Index
        attr_reader :top_dict

        def initialize(top_dict, *remaining_args)
          super(*remaining_args)
          @top_dict = top_dict
        end

        def [](index)
          data[index] ||= TTFunk::Table::Cff::Charstring.new(top_dict, get(index))
        end
      end
    end
  end
end
