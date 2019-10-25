# frozen_string_literal: true

module TTFunk
  class Table
    class Gsub
      module Lookup
        class Chaining2 < Base
          include Common::CoverageTableMixin

          attr_reader :format, :coverage_offset

          # backtrack class def offset, input class def offset,
          # lookahead class def offset
          attr_reader :bcd_offset, :icd_offset, :lcd_offset

          # chain sub class sets
          attr_reader :csc_sets

          def backtrack_class_def
            @backtrack_class_def ||= Common::ClassDef.create(
              self, table_offset + bcd_offset
            )
          end

          def input_class_def
            @input_class_def ||= Common::ClassDef.create(
              self, table_offset + icd_offset
            )
          end

          def lookahead_class_def
            @lookahead_class_def ||= Common::ClassDef.create(
              self, table_offset + lcd_offset
            )
          end

          def max_context
            @max_context ||= csc_sets.flat_map do |csc_set|
              csc_set.chain_sub_class_rules.map do |csc_rule|
                csc_rule.input_glyph_ids.count +
                  csc_rule.lookahead_glyph_ids.count
              end
            end.max
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format].pack('n')
              result << coverage_table.placeholder_relative_to(id)
              result << backtrack_class_def.placeholder
              result << input_class_def.placeholder
              result << lookahead_class_def.placeholder
              result << csc_sets.encode_to(result) do |csc_set|
                next [0] unless csc_set

                [csc_set.placeholder]
              end

              # Although not mentioned anywhere in the documentation, class
              # defs can be shared between backtrack, input, and lookahead.
              # This means there could be more than one placeholder per
              # class def table ID, necessitating the use of resolve_each.
              result.resolve_each(backtrack_class_def.id) do
                [result.length].pack('n')
              end

              result << backtrack_class_def.encode

              result.resolve_each(input_class_def.id) do
                [result.length].pack('n')
              end

              result << input_class_def.encode

              result.resolve_each(lookahead_class_def.id) do
                [result.length].pack('n')
              end

              result << lookahead_class_def.encode

              csc_sets.each do |chain_sub_class_set|
                next unless chain_sub_class_set

                result.resolve_placeholder(
                  chain_sub_class_set.id, [result.length].pack('n')
                )

                result << chain_sub_class_set.encode
              end
            end
          end

          def length
            @length + sum(csc_sets) do |cscs|
              cscs ? cscs.length : 0
            end
          end

          private

          def parse!
            @format, @coverage_offset, @bcd_offset,
              @icd_offset, @lcd_offset,
              count = read(12, 'n6')

            @csc_sets = Sequence.from(io, count, 'n') do |csc_set_offset|
              # "If no contexts begin with a particular class (that is, if a
              # ChainSubClassSet contains no ChainSubClassRule tables), then
              # the offset to that particular ChainSubClassSet in the
              # ChainSubClassSet array will be set to NULL." (i.e. 0)
              if csc_set_offset > 0
                Gsub::ChainSubClassSet.new(file, table_offset + csc_set_offset)
              end
            end

            @length = 12 + csc_sets.length
          end
        end
      end
    end
  end
end
