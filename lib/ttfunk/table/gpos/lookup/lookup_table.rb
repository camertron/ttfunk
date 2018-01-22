module TTFunk
  class Table
    class Gpos
      module Lookup
        class LookupTable < Common::LookupTable
          SUB_TABLE_MAP = {
            1 => Single,
            2 => PairAdjustment,
            3 => Cursive,
            4 => MarkToBase,
            5 => MarkToLigature,
            6 => MarkToMark,
            7 => Contextual,
            8 => Chaining,
          }

          # @TODO
          # EXTENSION_LOOKUP_TYPE = Extension::LOOKUP_TYPE
          # EXTENSION_CLASS = SUB_TABLE_MAP[EXTENSION_LOOKUP_TYPE]
        end
      end
    end
  end
end
