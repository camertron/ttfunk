module TTFunk
  class Table
    class Gpos
      module Lookup
        class Single1 < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :value_format, :value_table

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << coverage_table.placeholder
              result << [value_format].pack('n')
              result << value_table.encode
            end
          end

          private

          def parse!
            @format, @coverage_offset, @value_format = read(6, 'nnn')
            @value_table = ValueTable.new(file, io.pos, value_format, table_offset)
            @length = 6 + value_table.length
          end
        end
      end
    end
  end
end
