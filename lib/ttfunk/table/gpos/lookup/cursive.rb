module TTFunk
  class Table
    class Gpos
      module Lookup
        class Cursive < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :entry_exits

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << coverage_table.placeholder
              result << [entry_exits.count].pack('n')
              entry_exits.encode_to(result) do |entry_exit|
                [entry_exit.placeholder]
              end

              entry_exits.each do |entry_exit|
                result.resolve_each(entry_exit.id) { [result.length].pack('n') }
                result << entry_exit.encode
              end
            end
          end

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'nnn')

            @entry_exits = Sequence.from(io, count, 'n') do |entry_exit_offset|
              EntryExitTable.new(file, table_offset + entry_exit_offset)
            end

            @length = 6 + entry_exits.length
          end
        end
      end
    end
  end
end
