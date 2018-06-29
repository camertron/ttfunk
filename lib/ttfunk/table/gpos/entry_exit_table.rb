module TTFunk
  class Table
    class Gpos
      class EntryExitTable < TTFunk::SubTable
        # NOTE: these are supposed to be relative to the Cursive lookup table,
        # which is weird considering that would be the only time I'm aware of
        # that a dependent sub table is not offset relative to its immediate
        # parent.
        attr_reader :entry_anchor_offset, :exit_anchor_offset

        def encode
          EncodedString.new  # @TODO: figure this table out
        end

        private

        def parse!
          @entry_anchor_offset, @exit_anchor_offset = read(4, 'nn')
        end
      end
    end
  end
end
