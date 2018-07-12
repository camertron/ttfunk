module TTFunk
  class Table
    class Gpos
      class EntryExitTable < TTFunk::SubTable
        attr_reader :cursive_lookup_table
        attr_reader :entry_anchor_offset, :exit_anchor_offset

        def entry_anchor
          @entry_anchor ||= AnchorTable.create(file, self, entry_anchor_offset)
        end

        def exit_anchor
          @exit_anchor ||= AnchorTable.create(file, self, exit_anchor_offset)
        end

        def initialize(file, offset, cursive_lookup_table)
          @cursive_lookup_table = cursive_lookup_table
          super(file, offset)
        end

        def encode
          EncodedString.new do |result|
            result << entry_anchor.placeholder_relative_to(cursive_lookup_table)
            result << exit_anchor.placeholder_relative_to(cursive_lookup_table)
          end
        end

        def finalize(data)
          data.resolve_each(entry_anchor.id) do |placeholder|
            [data.length - data.tag_for(placeholder).position].pack('n')
          end

          data << entry_anchor.encode

          data.resolve_each(exit_anchor.id) do |placeholder|
            [data.length - data.tag_for(placeholder).position].pack('n')
          end

          data << exit_anchor.encode
        end

        private

        def parse!
          @entry_anchor_offset, @exit_anchor_offset = read(4, 'nn')
        end
      end
    end
  end
end
