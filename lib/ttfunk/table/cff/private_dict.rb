module TTFunk
  class Table
    class Cff < TTFunk::Table
      class PrivateDict < TTFunk::Table::Cff::Dict
        DEFAULT_WIDTH_X_DEFAULT = 0
        DEFAULT_WIDTH_X_NOMINAL = 0

        OPERATOR_MAP = {
          subrs: 19,
          default_width_x: 20,
          nominal_width_x: 21
        }

        def subr_index
          @subr_index ||= begin
            if subr_offset = self[OPERATOR_MAP[:subrs]]
              SubrIndex.new(file, table_offset + subr_offset)
            end
          end
        end

        def default_width_x
          self[OPERATOR_MAP[:default_width_x]] || DEFAULT_WIDTH_X_DEFAULT
        end

        def nominal_width_x
          self[OPERATOR_MAP[:nominal_width_x]] || DEFAULT_WIDTH_X_NOMINAL
        end
      end
    end
  end
end
