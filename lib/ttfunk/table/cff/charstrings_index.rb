module TTFunk
  class Table
    class Cff < TTFunk::Table
      class CharstringsIndex < TTFunk::Table::Cff::Index
        attr_reader :top_dict

        def initialize(top_dict, *remaining_args)
          super(*remaining_args)
          @top_dict = top_dict
        end

        def [](index)
          data[index] ||= begin
            TTFunk::Table::Cff::Charstring.new(
              index, top_dict, font_dict_for(index), super
            )
          end
        end

        # gets passed a mapping of new => old glyph ids
        def encode(mapping)
          super() do |entry, index|
            self[mapping[index]].encode if mapping.include?(index)
          end
        end

        private

        def font_dict_for(index)
          # Only CID-keyed fonts contain an FD selector and font dicts. CID-keyed
          # fonts have a ROS operator in their top dicts.
          if top_dict.ros?
            fd_index = top_dict.font_dict_selector[index]
            font_dict = top_dict.font_index[fd_index]
          end
        end
      end
    end
  end
end
