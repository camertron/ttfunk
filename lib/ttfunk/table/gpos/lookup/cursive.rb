module TTFunk
  class Table
    class Gpos
      module Lookup
        class Cursive < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :lookup_type
          attr_reader :format, :coverage_offset, :entry_exits

          def self.create(file, _parent_table, offset, lookup_type)
            new(file, offset, lookup_type)
          end

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

          def dependent_coverage_tables
            [coverage_table]
          end

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << Placeholder.new("gsub_#{coverage_table.id}", length: 2, relative_to: 0)
              result << [entry_exits.count].pack('n')
              entry_exits.encode_to(result) do |entry_exit|
                [Placeholder.new("gpos_#{entry_exit.id}", length: 2)]
              end

              entry_exits.each do |entry_exit|
                result.resolve_placeholder(
                  "gpos_#{entry_exit.id}", [result.length].pack('n')
                )

                result << entry_exit.encode
              end
            end
          end

          def finalize(data)
            if data.placeholders.include?("gpos_#{coverage_table.id}")
              data.resolve_each("gpos_#{coverage_table.id}") do |placeholder|
                [data.length - placeholder.relative_to].pack('n')
              end

              data << coverage_table.encode
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
