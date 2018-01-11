module TTFunk
  class Table
    class Gsub
      class Alternate < TTFunk::SubTable
        attr_reader :format, :coverage_offset, :alternate_sets

        def self.create(file, _parent_table, offset)
          new(file, offset)
        end

        def coverage_table
          @coverage_table ||= Common::CoverageTable.create(
            file, self, table_offset + coverage_offset
          )
        end

        def max_context
          1
        end

        def encode
          EncodedString.create do |result|
            result.write(format, 'n')
            result << ph(:gsub, coverage_table.id, length: 2, relative_to: 0)
            result.write(alternate_sets.count, 'n')

            result << alternate_sets.encode do |alternate_set|
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
