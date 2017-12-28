module TTFunk
  class Directory
    attr_reader :tables
    attr_reader :sfnt_version

    def initialize(io, offset = 0)
      io.seek(offset)

      # https://www.microsoft.com/typography/otspec/otff.htm#offsetTable
      # We're ignoring searchRange, entrySelector, and rangeShift here, but
      # skipping past them to get to the table information. Change the "Nn"
      # to "Nn*" to decode those fields as well.
      @sfnt_version, table_count = io.read(12).unpack('Nn')

      @tables = {}
      table_count.times do
        tag, checksum, offset, length = io.read(16).unpack('a4N*')
        @tables[tag] = {
          tag: tag,
          checksum: checksum,
          offset: offset,
          length: length
        }
      end
    end
  end
end
