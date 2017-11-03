module TTFunk
  class Table
    class Cff < TTFunk::Table
      class SubrIndex < TTFunk::Table::Cff::Index
        # ignore charstring type for now
        # (this stuff is for charstrings type 2)
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
