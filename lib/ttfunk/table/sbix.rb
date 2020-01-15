# frozen_string_literal: true

require_relative '../table'

module TTFunk
  class Table
    class Sbix < Table
      attr_reader :version
      attr_reader :flags
      attr_reader :num_strikes
      attr_reader :strikes

      BitmapData = Struct.new(:x, :y, :type, :data, :ppem, :resolution)

      def self.encode(sbix, new_to_old)
        EncodedString.new do |table|
          max_gid = new_to_old.keys.max
          table << [sbix.version, sbix.flags, sbix.num_strikes].pack('n2N')

          sbix.strikes.each_index do |strike_index|
            table << Placeholder.new("strike_#{strike_index}", length: 4)
          end

          sbix.strikes.each_with_index do |strike, strike_index|
            table.resolve_placeholder("strike_#{strike_index}", [table.length].pack('N'))
            table << [strike[:ppem], strike[:resolution]].pack('n2')
            data_offset = 4

            0.upto(max_gid + 1) do |new_gid|
              table << Placeholder.new("bmp_#{new_gid}", length: 4)
              data_offset += 4
            end

            0.upto(max_gid) do |new_gid|
              table.resolve_placeholder("bmp_#{new_gid}", [data_offset].pack('N'))
              old_gid = new_to_old[new_gid]

              if data = sbix.raw_bitmap_data_for(old_gid, strike_index)
                table << data
                data_offset += data.bytesize
              end
            end

            table.resolve_placeholder("bmp_#{max_gid + 1}", [data_offset].pack('N'))
          end
        end
      end

      def bitmap_data_for(glyph_id, strike_index)
        if (bitmap_data = raw_bitmap_data_for(glyph_id, strike_index))
          strike = strikes[strike_index]
          x, y, type = bitmap_data.unpack('s2A4')
          data = StringIO.new(bitmap_data[8..-1])
          BitmapData.new(
            x, y, type, data, strike[:ppem], strike[:resolution]
          )
        end
      end

      def all_bitmap_data_for(glyph_id)
        strikes.each_index.map do |strike_index|
          bitmap_data_for(glyph_id, strike_index)
        end.compact
      end

      def raw_bitmap_data_for(glyph_id, strike_index)
        strike = strikes[strike_index]
        return if strike.nil?

        glyph_offset = strike[:glyph_data_offset][glyph_id]
        next_glyph_offset = strike[:glyph_data_offset][glyph_id + 1]

        if glyph_offset && next_glyph_offset
          bytes = next_glyph_offset - glyph_offset

          if bytes > 0
            parse_from(offset + strike[:offset] + glyph_offset) do
              io.read(bytes)
            end
          end
        end
      end

      private

      def parse!
        @version, @flags, @num_strikes = read(8, 'n2N')
        strike_offsets = Array.new(num_strikes) { read(4, 'N').first }

        @strikes = strike_offsets.map do |strike_offset|
          parse_from(offset + strike_offset) do
            ppem, resolution = read(4, 'n2')
            data_offsets = Array.new(file.maximum_profile.num_glyphs + 1) do
              read(4, 'N').first
            end
            {
              ppem: ppem,
              resolution: resolution,
              offset: strike_offset,
              glyph_data_offset: data_offsets
            }
          end
        end
      end
    end
  end
end
