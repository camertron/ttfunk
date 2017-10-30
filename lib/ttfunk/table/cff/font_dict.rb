module TTFunk
  class Table
    class Cff < TTFunk::Table
      class FontDict < TTFunk::Table::Cff::Dict
        private

        def parse!
          super
        end
      end
    end
  end
end
