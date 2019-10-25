# frozen_string_literal: true

module TTFunk
  class Table
    class Gsub
      module Lookup
        class Chaining3 < Base
          attr_reader :format

          # backtrack coverage tables, input coverage tables,
          # lookahead coverage tables, subst lookup tables
          attr_reader :btc_tables, :ic_tables, :lac_tables, :sl_tables

          def max_context
            ic_tables.count + lac_tables.count
          end

          def dependent_coverage_tables
            btc_tables.to_a +
              ic_tables.to_a +
              lac_tables.to_a
          end

          def encode
            EncodedString.new do |result|
              result.tag_with(id)
              result << [format, btc_tables.count].pack('nn')

              btc_tables.encode_to(result) do |btc_table|
                [btc_table.placeholder_relative_to(id)]
              end

              result << [ic_tables.count].pack('n')

              ic_tables.encode_to(result) do |ic_table|
                [ic_table.placeholder_relative_to(id)]
              end

              result << [lac_tables.count].pack('n')

              lac_tables.encode_to(result) do |lac_table|
                [lac_table.placeholder_relative_to(id)]
              end

              result << [sl_tables.count].pack('n')

              sl_tables.encode_to(result) do |sl_table|
                [
                  sl_table.glyph_sequence_index,
                  sl_table.lookup_list_index
                ]
              end
            end
          end

          def length
            @length +
              sum(btc_tables, &:length) +
              sum(ic_tables, &:length) +
              sum(lac_tables, &:length)
          end

          private

          def parse!
            # format, backtrack count
            @format, bt_count = read(4, 'nn')
            @btc_tables = Sequence.from(io, bt_count, 'n') do |ct_offset|
              Common::CoverageTable.create(
                file, self, table_offset + ct_offset
              )
            end

            input_count = read(2, 'n').first
            @ic_tables = Sequence.from(io, input_count, 'n') do |ct_offset|
              Common::CoverageTable.create(
                file, self, table_offset + ct_offset
              )
            end

            # lookahead count
            la_count = read(2, 'n').first
            @lac_tables = Sequence.from(io, la_count, 'n') do |ct_offset|
              Common::CoverageTable.create(
                file, self, table_offset + ct_offset
              )
            end

            subst_count = read(2, 'n').first
            fmt = Gsub::SubstLookupTable::FORMAT
            @sl_tables = Sequence.from(io, subst_count, fmt) do |*args|
              Gsub::SubstLookupTable.new(*args)
            end

            @length = 10 + btc_tables.length +
              ic_tables.length +
              lac_tables.length +
              sl_tables.length
          end
        end
      end
    end
  end
end
