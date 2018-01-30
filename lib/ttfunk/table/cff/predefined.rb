module TTFunk
  class Table
    class Cff
      class Predefined
        class << self
          def standard_strings
            @standard_strings ||= load_file('standard_strings.yml')
          end

          def standard_encoding
            @standard_encoding ||= load_file('standard_encoding.yml')
          end

          def expert_encoding
            @expert_encoding ||= load_file('expert_encoding.yml')
          end

          def standard_names
            @standard_names ||= load_file('standard_names.yml')
          end

          private

          def load_file(file)
            YAML.load_file(
              ::File.expand_path(::File.join('..', 'predefined', file), __FILE__)
            )
          end
        end
      end
    end
  end
end
