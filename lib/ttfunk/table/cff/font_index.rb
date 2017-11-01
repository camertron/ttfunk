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
            start, finish = data_offsets_for(index)
            TTFunk::Table::Cff::FontDict.new(file, table_offset + start + 4)
          end
        end
      end
    end
  end
end
