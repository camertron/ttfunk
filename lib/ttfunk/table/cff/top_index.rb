module TTFunk
  class Table
    class Cff < TTFunk::Table
      class TopIndex < TTFunk::Table::Cff::Index
        def [](index)
          data[index] ||= begin
            start, finish = data_offsets_for(index)
            TTFunk::Table::Cff::TopDict.new(file, table_offset + start + 4)
          end
        end
      end
    end
  end
end
