module TTFunk
  class Table
    class Gpos
      module Lookup
        class Cursive < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :entry_exits

          def self.create(file, _parent_table, offset, lookup_type)
            new(file, offset, lookup_type)
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
