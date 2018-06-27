module TTFunk
  class Table
    class Gpos
      module Lookup
        class Contextual2 < TTFunk::SubTable
          include Common::CoverageTableMixin

          attr_reader :lookup_type
          attr_reader :format, :coverage_offset, :class_def_offset
          attr_reader :pos_class_sets

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

          def class_def
            @class_def ||= Common::ClassDef.create(
              self, table_offset + class_def_offset
            )
          end

          def dependent_coverage_tables
            [coverage_table]
          end

          def encode
            EncodedString.new do |result|
              result << [format].pack('n')
              result << Placeholder.new("gpos_#{coverage_table.id}", length: 2, relative_to: 0)
              result << Placeholder.new("gpos_#{class_def.id}", length: 2)
              result << [pos_class_sets.count].pack('n')
              pos_class_sets.encode_to(result) do |pos_class_set|
                if pos_class_set
                  [Placeholder.new("gpos_#{pos_class_set.id}", length: 2)]
                else
                  [0]
                end
              end

              result.resolve_placeholder(
                "gpos_#{class_def.id}", [result.length].pack('n')
              )

              result << class_def.encode

              pos_class_sets.each do |pos_class_set|
                next unless pos_class_set

                result.resolve_placeholder(
                  "gpos_#{pos_class_set.id}", [result.length].pack('n')
                )

                result << pos_class_set.encode
              end
            end
          end

          def finalize(data)
            if data.has_placeholders?("gpos_#{coverage_table.id}")
              data.resolve_each("gpos_#{coverage_table.id}") do |placeholder|
                [data.length - placeholder.relative_to].pack('n')
              end

              data << coverage_table.encode
            end
          end

          def length
            @length + sum(pos_class_sets) { |pcs| pcs&.length || 0 }
          end

          private

          def parse!
            @format, @coverage_offset, @class_def_offset, count = read(10, 'n5')

            @pos_class_sets = Sequence.from(io, count, 'n') do |pos_class_offset|
              PosClassSet.new(file, table_offset + pos_class_offset)
            end

            @length = 10 + pos_class_sets.length
          end
        end
      end
    end
  end
end
