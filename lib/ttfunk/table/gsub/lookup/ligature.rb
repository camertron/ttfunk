module TTFunk
  class Table
    class Gsub
      module Lookup
        class Ligature < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset, :ligature_sets

          def max_context
            @max_context ||= ligature_sets.flat_map do |ligature_set|
              ligature_set.tables.map do |ligature_table|
                ligature_table.component_glyph_ids.count
              end
            end.max
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format].pack('n')
              result << coverage_table.placeholder_relative_to(id)
              result << [ligature_sets.count].pack('n')
              ligature_sets.encode_to(result) do |ligature_set|
                [ligature_set.placeholder]
              end

              ligature_sets.each do |ligature_set|
                result.resolve_placeholder(
                  ligature_set.id, [result.length].pack('n')
                )

                result << ligature_set.encode
              end
            end
          end

          def length
            @length + sum(ligature_sets, &:length)
          end

          private

          def parse!
            @format, @coverage_offset, count = read(6, 'nnn')

            @ligature_sets = Sequence.from(io, count, 'n') do |ligature_set_offset|
              Gsub::LigatureSet.new(file, table_offset + ligature_set_offset)
            end

            @length = 6 + ligature_sets.length
          end
        end
      end
    end
  end
end
