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
          data[index] ||= begin
            fd_index = top_dict.font_dict_selector[index]
            font_dict = top_dict.font_index[fd_index]
            TTFunk::Table::Cff::Charstring.new(index, top_dict, font_dict, get(index))
          end
        end
      end
    end
  end
end
