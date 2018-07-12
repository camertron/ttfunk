module TTFunk
  class Table
    class Gpos
      module Lookup
        class Single2 < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :value_format, :value_tables

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format].pack('n')
              result << coverage_table.placeholder_relative_to(id)
              result << [value_format, value_tables.size].pack('n*')

              value_tables.each do |value_table|
                result << value_table.encode
              end
            end
          end

          def finalize(data)
            value_tables.each { |value_table| value_table.finalize(data) }
            super
          end

          private

          def parse!
            @format, @coverage_offset, @value_format, count = read(8, 'n*')

            @value_tables = Array.new(count) do
              ValueTable.new(file, io.pos, value_format, self)
            end

            @length = 8 + sum(value_tables, &:length)
          end
        end
      end
    end
  end
end
