module TTFunk
  class Table
    class Gsub
      class LookupTable < Common::LookupTable
        SUB_TABLE_MAP = {
          1 => Gsub::Single,
          2 => Gsub::Multiple,
          3 => Gsub::Alternate,
          4 => Gsub::Ligature,
          5 => Gsub::Contextual,
          6 => Gsub::Chaining,
          7 => Gsub::Extension,
          8 => Gsub::ReverseChaining
        }
      end
    end
  end
end
