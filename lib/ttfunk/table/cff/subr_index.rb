module TTFunk
  class Table
    class Cff < TTFunk::Table
      class SubrIndex < TTFunk::Table::Cff::Index
        def [](index)
          data[index] ||= self[index].bytes
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
