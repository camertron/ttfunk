# frozen_string_literal: true

module TTFunk
  class Table
    class Gsub
      module Lookup
        class Base < TTFunk::SubTable
          def self.create(file, _parent_table, offset, lookup_type)
            new(file, offset, lookup_type)
          end

          attr_reader :lookup_type

          def initialize(file, offset, lookup_type)
            @lookup_type = lookup_type
            super(file, offset)
          end

          # override in derived classes if more finalization steps are necessary
          def finalize(data)
            finalize_coverage_tables(dependent_coverage_tables, data)
          end

          def finalize_coverage_tables(coverage_tables, data)
            coverage_tables.each do |cov_table|
              next unless data.placeholders.include?(cov_table.id)

              data.resolve_each(cov_table.id) do |placeholder|
                [data.length - data.tag_for(placeholder).position].pack('n')
              end

              data << cov_table.encode
            end
          end

          # implement by either mixing in CoverageTableMixin or by defining
          # your own
          def dependent_coverage_tables
            raise NotImplementedError, "#{__method__} must be defined in "\
              'derived classes'
          end
        end
      end
    end
  end
end
