module TTFunk
  class Table
    class Gsub
      module Lookup
        class Single1 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :lookup_type, :format, :coverage_offset, :delta_glyph_id

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
              result << [delta_glyph_id].pack('n')
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

          private

          def parse!
            @format, @coverage_offset, @delta_glyph_id = read(6, 'nnn')
            @length = 6
          end
        end
      end
    end
  end
end
