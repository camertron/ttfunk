module TTFunk
  class Table
    class Gsub
      class Alternate < TTFunk::SubTable
        attr_reader :lookup_type, :format, :coverage_offset, :alternate_sets

        def self.create(file, _parent_table, offset, lookup_type)
          new(file, offset, lookup_type)
        end

        def initialize(file, offset, lookup_type)
          @lookup_type = lookup_type
          super(file, offset)
        end

        def coverage_table
          @coverage_table ||= Common::CoverageTable.create(
            file, self, table_offset + coverage_offset
          )
        end

        def max_context
          1
        end

        def dependent_coverage_tables
          [coverage_table]
        end

        def encode
          EncodedString.create do |result|
            result.write(format, 'n')
            result << ph(:gsub, coverage_table.id, length: 2, relative_to: 0)
            result.write(alternate_sets.count, 'n')

            alternate_sets.encode_to(result) do |alternate_set|
              [ph(:gsub, alternate_set.id, length: 2)]
            end

            alternate_sets.each do |alternate_set|
              result.resolve_placeholders(
                :gsub, alternate_set.id, [result.length].pack('n')
              )

              result << alternate_set.encode
            end
          end
        end

        def finalize(data)
          if data.has_placeholders?(:gsub, coverage_table.id)
            data.resolve_each(:gsub, coverage_table.id) do |placeholder|
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
            Common::AlternateSet.new(file, table_offset + alternate_set_offset)
          end

          @length = 6 + alternate_sets.length
        end
      end
    end
  end
end
