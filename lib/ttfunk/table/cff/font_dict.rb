module TTFunk
  class Table
    class Cff < TTFunk::Table
      class FontDict < TTFunk::Table::Cff::Dict
        OPERATOR_MAP = {
          private: 18
        }

        attr_reader :top_dict

        def initialize(top_dict, file, offset, length = nil)
          super(file, offset, length)
          @top_dict = top_dict
        end

        def private_dict
          @private_dict ||= begin
            if info = self[OPERATOR_MAP[:private]]
              private_dict_length, private_dict_offset = info
              PrivateDict.new(file, top_dict.cff_offset + private_dict_offset, private_dict_length)
            end
          end
        end
      end
    end
  end
end
