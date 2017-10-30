module TTFunk
  class Table
    class Cff < TTFunk::Table
      class SubrIndex < TTFunk::Table::Cff::Index
        def [](index)
          data[index] ||= begin
            start, finish = data_offsets_for(index)
            @raw_data_array[start...finish].bytes
          end
        end

        # ignore charstring type for now
        def bias
          if count < 1240
            107
          elsif count < 33900
            1131
          else
            32768
          end
        end
      end
    end
  end
end
