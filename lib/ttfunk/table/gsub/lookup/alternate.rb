module TTFunk
  class Table
    class Gsub
      module Lookup
        class Alternate < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :lookup_type, :format, :coverage_offset, :alternate_sets

          def self.create(file, _parent_table, offset, lookup_type)
            new(file, offset, lookup_type)
          end

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

          def max_context
            1
          end

          def dependent_coverage_tables
            [coverage_table]
          end

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << Placeholder.new("gsub_#{coverage_table.id}", length: 2, relative_to: 0)
              result << [alternate_sets.count].pack('n')

              alternate_sets.encode_to(result) do |alternate_set|
                [Placeholder.new("gsub_#{alternate_set.id}", length: 2)]
              end

              alternate_sets.each do |alternate_set|
                result.resolve_placeholder(
                  "gsub_#{alternate_set.id}", [result.length].pack('n')
                )

                result << alternate_set.encode
              end
            end
          end

          def finalize(data)
            if data.placeholders.include?("gsub_#{coverage_table.id}")
              data.resolve_each("gsub_#{coverage_table.id}") do |placeholder|
                [data.length - placeholder.relative_to].pack('n')
              end

              data << coverage_table.encode
            end
          end

          def length
            @length + sum(alternate_sets, &:length)
          end

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'nnn')

            @alternate_sets = Sequence.from(io, count, 'n') do |alternate_set_offset|
              Gsub::AlternateSet.new(file, table_offset + alternate_set_offset)
            end

            @length = 6 + alternate_sets.length
          end
        end
      end
    end
  end
end
