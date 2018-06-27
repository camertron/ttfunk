module TTFunk
  class Table
    class Gsub
      module Lookup
        class Base < TTFunk::SubTable
          attr_reader :lookup_type

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end
        end
      end
    end
  end
end
