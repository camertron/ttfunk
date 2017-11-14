module TTFunk
  class Table
    class Cmap < Simple
      def initialize(file)
        super(file, 'BASE')
      end
    end
  end
end
