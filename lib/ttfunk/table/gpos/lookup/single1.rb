module TTFunk
  class Table
    class Gpos
      module Lookup
        class Single1 < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :value_format, :value_table

          def max_context
            1
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format].pack('n')
              result << coverage_table.placeholder_relative_to(id)
              result << [value_format].pack('n')
              result << value_table.encode
            end
          end

          def finalize(data)
            value_table.finalize(data)
            super
          end

          private

          def parse!
            @format, @coverage_offset, @value_format = read(6, 'nnn')
            @value_table = ValueTable.new(file, io.pos, value_format, self)
            @length = 6 + value_table.length
          end
        end
      end
    end
  end
end
