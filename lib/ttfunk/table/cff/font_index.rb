module TTFunk
  class Table
    class Cff < TTFunk::Table
      class FontIndex < TTFunk::Table::Cff::Index
        attr_reader :top_dict

        def initialize(top_dict, file, offset, length = nil)
          super(file, offset, length)
          @top_dict = top_dict
        end

        def [](index)
          data[index] ||= begin
            start, finish = absolute_data_offsets_for(index)
            TTFunk::Table::Cff::FontDict.new(top_dict, file, start, finish - start)
          end
        end
      end
    end
  end
end
