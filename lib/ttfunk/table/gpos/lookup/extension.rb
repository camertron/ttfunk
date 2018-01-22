module TTFunk
  class Table
    class Gpos
      module Lookup
        class Extension < TTFunk::SubTable
          FORMAT = 1
          LOOKUP_TYPE = 9

          attr_reader :format, :extension_lookup_type, :extension_offset

          private

          def parse!
            @format, @extension_lookup_type, @extension_offset = read(8, 'nnN')
            @length = 8
          end
        end
      end
    end
  end
end
