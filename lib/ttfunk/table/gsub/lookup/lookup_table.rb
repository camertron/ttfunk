# frozen_string_literal: true

module TTFunk
  class Table
    class Gsub
      module Lookup
        class LookupTable < Common::LookupTable
          SUB_TABLE_MAP = {
            1 => Single,
            2 => Multiple,
            3 => Alternate,
            4 => Ligature,
            5 => Contextual,
            6 => Chaining,
            7 => Extension,
            8 => ReverseChaining
          }.freeze

          EXTENSION_LOOKUP_TYPE = Extension::LOOKUP_TYPE
          EXTENSION_CLASS = SUB_TABLE_MAP[EXTENSION_LOOKUP_TYPE]
        end
      end
    end
  end
end
