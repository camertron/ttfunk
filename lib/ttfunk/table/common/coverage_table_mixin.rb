module TTFunk
  class Table
    module Common
      module CoverageTableMixin
        # expects host class to define file, table_offset,
        # and coverage_offset
        def coverage_table
          @coverage_table ||= Common::CoverageTable.create(
            file, self, table_offset + coverage_offset
          )
        end

        # override in derived classes if this table depends on more than one
        # coverage table
        def dependent_coverage_tables
          [coverage_table]
        end
      end
    end
  end
end
