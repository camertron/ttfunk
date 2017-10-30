module TTFunk
  class Table
    class Cff < TTFunk::Table
      class FontIndex < TTFunk::Table::Cff::Index
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
