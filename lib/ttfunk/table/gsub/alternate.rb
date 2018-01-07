module TTFunk
  class Table
    class Gsub
      class Alternate < TTFunk::SubTable
        attr_reader :format, :coverage_offset, :alternate_sets

        def self.create(file, _parent_table, offset)
          new(file, offset)
        end

        def coverage_table
          @coverage_table ||= CoverageTable.create(
            file, self, table_offset + coverage_offset
          )
        end

        def max_context
          1
        end

        private

        def parse!
          @format, @coverage_offset, count = read(6, 'nnn')

          @alternate_sets = Sequence.from(io, count, 'n') do |alternate_set_offset|
            AlternateSet.new(file, table_offset + alternate_set_offset)
          end

          @length = 6 + alternate_sets.length
        end
      end
    end
  end
end
