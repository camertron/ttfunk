module TTFunk
  class Table
    class Cff < TTFunk::Table
      class TopIndex < TTFunk::Table::Cff::Index
        attr_reader :cff

        def initialize(cff, *remaining_args)
          super(*remaining_args)
          @cff = cff
        end

        def [](index)
          data[index] ||= begin
            start, finish = relative_data_offsets_for(index)  # @TODO is this wrong?
            TTFunk::Table::Cff::TopDict.new(cff, file, table_offset + start + 4)
          end
        end
      end
    end
  end
end
