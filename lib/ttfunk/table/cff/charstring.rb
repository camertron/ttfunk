module TTFunk
  class Table
    class Cff < TTFunk::Table
      class Charstring
        CODE_MAP = {
          1  => :hstem,
          3  => :vstem,
          4  => :vmoveto,
          5  => :rlineto,
          6  => :hlineto,
          7  => :vlineto,
          8  => :rrcurveto,
          10 => :callsubr,
          12 => :flex_select,
          14 => :endchar,
          18 => :hstemhm,
          19 => :hintmask,
          20 => :cntrmask,
          21 => :rmoveto,
          22 => :hmoveto,
          23 => :vstemhm,
          24 => :rcurveline,
          25 => :rlinecurve,
          26 => :vvcurveto,
          27 => :hhcurveto,
          28 => :shortint,
          29 => :callgsubr,
          30 => :vhcurveto,
          31 => :hvcurveto
        }

        FLEX_CODE_MAP = {
          35 => :flex,
          34 => :hflex,
          36 => :hflex1,
          37 => :flex1
        }

        attr_reader :raw, :path

        def initialize(top_dict, raw)
          @top_dict = top_dict
          @raw = raw
          @path = Path.new
          @stack = []
          @frames = [StringIO.new(raw)]
          @n_stems = 0
          @have_width = false
          @open = false
          @width = default_width_x
          @x = 0
          @y = 0

          parse!
        end

        private

        def parse!
          until eof?
            code = read_byte

            case code
              when 11
                break
              when *CODE_MAP.keys
                send(CODE_MAP[code])
              when 32..246
                @stack.push(code - 139)
              when 247..250
                b0 = code
                b1 = read_byte
                @stack.push((b0 - 247) * 256 + b1 + 108)
              when 251..254
                b0 = code
                b1 = read_byte
                @stack.push(-(b0 - 251) * 256 - b1 - 108)
              when 255
                b0 = code
                b1 = read_byte
                b2 = read_byte
                b3 = read_byte
                b4 = read_byte
                @stack.push(((b1 << 24) | (b2 << 16) | (b3 << 8) | b4) / 65536)
              else
                # bad
            end
          end
        end

        def read_byte
          return nil if @frames.empty?

          @frames.last.read(1).ord.tap do
            @frames.pop if @frames.last.eof?
          end
        end

        def eof?
          @frames.empty?
        end

        def default_width_x
          binding.pry
          @top_dict.private_dict.default_width_x
        end

        def nominal_width_x
          @top_dict.private_dict.nominal_width_x
        end

        def subrs_bias
          subrs.bias
        end

        def gsubrs_bias
          gsubrs.bias
        end

        def subrs
          @top_dict.private_dict.subr_index
        end

        def gsubrs
          cff.global_subr_index
        end

        def hstem
          stem
        end

        def vstem
          stem
        end

        def stem
          # The number of stem operators on the stack is always even.
          # If the value is uneven, that means a width is specified.
          has_width_arg = @stack.size.odd?

          if has_width_arg && !@have_width
            @width = @stack.shift + nominal_width_x
          end

          @n_stems += @stack.length >> 1
          @stack.clear
          @have_width = true
        end

        def vmoveto
          if @stack.size > 1 && !@have_width
            @width = @stack.shift + nominal_width_x
            @have_width = true
          end

          @y += @stack.pop
          add_contour(@x, @y)
        end

        def add_contour(x, y)
          if @open
            @path.close_path
          end

          @path.move_to(x, y)
          @open = true
        end

        def rlineto
          until @stack.empty?
            @x += @stack.shift
            @y += @stack.shift
            @path.line_to(@x, @y)
          end
        end

        def hlineto
          until @stack.empty?
            @x += @stack.shift
            @path.line_to(@x, @y)

            break if @stack.empty?

            @y += @stack.shift
            @path.line_to(@x, @y)
          end
        end

        def vlineto
          until @stack.empty?
            @y += @stack.shift
            @path.line_to(@x, @y)

            break if @stack.empty?

            @x += @stack.shift
            @path.line_to(@x, @y)
          end
        end

        def rrcurveto
          until @stack.empty?
            c1x = @x + @stack.shift
            c1y = @y + @stack.shift
            c2x = c1x + @stack.shift
            c2y = c1y + @stack.shift
            @x = c2x + @stack.shift
            @y = c2y + @stack.shift
            @path.curve_to(c1x, c1y, c2x, c2y, @x, @y)
          end
        end

        def callsubr
          code_index = @stack.pop + subrs_bias
          subr_codes = subrs[code_index]
          @frames.push(StringIO.new(subr_codes)) if subr_codes
        end

        def flex_select
          flex_code = read_byte
          send(FLEX_CODE_MAP[flex_code])
        end

        def flex
          c1x = @x  + @stack.shift    # dx1
          c1y = @y  + @stack.shift    # dy1
          c2x = c1x + @stack.shift    # dx2
          c2y = c1y + @stack.shift    # dy2
          jpx = c2x + @stack.shift    # dx3
          jpy = c2y + @stack.shift    # dy3
          c3x = jpx + @stack.shift    # dx4
          c3y = jpy + @stack.shift    # dy4
          c4x = c3x + @stack.shift    # dx5
          c4y = c3y + @stack.shift    # dy5
          @x  = c4x + @stack.shift    # dx6
          @y  = c4y + @stack.shift    # dy6
          @stack.shift                # flex depth

          @path.curve_to(c1x, c1y, c2x, c2y, jpx, jpy)
          @path.curve_to(c3x, c3y, c4x, c4y, @x, @y)
        end

        def hflex
          c1x = @x  + @stack.shift    # dx1
          c1y = @y                    # dy1
          c2x = c1x + @stack.shift    # dx2
          c2y = c1y + @stack.shift    # dy2
          jpx = c2x + @stack.shift    # dx3
          jpy = c2y                   # dy3
          c3x = jpx + stack.shift     # dx4
          c3y = c2y                   # dy4
          c4x = c3x + stack.shift     # dx5
          c4y = @y                    # dy5
          @x  = c4x + stack.shift     # dx6

          @path.curve_to(c1x, c1y, c2x, c2y, jpx, jpy)
          @path.curve_to(c3x, c3y, c4x, c4y, @x, @y)
        end

        def hflex1
          c1x = @x  + @stack.shift    # dx1
          c1y = @y  + @stack.shift    # dy1
          c2x = c1x + @stack.shift    # dx2
          c2y = c1y + @stack.shift    # dy2
          jpx = c2x + @stack.shift    # dx3
          jpy = c2y                   # dy3
          c3x = jpx + @stack.shift    # dx4
          c3y = c2y                   # dy4
          c4x = c3x + @stack.shift    # dx5
          c4y = c3y + @stack.shift    # dy5
          @x  = c4x + @stack.shift    # dx6

          @path.curve_to(c1x, c1y, c2x, c2y, jpx, jpy)
          @path.curve_to(c3x, c3y, c4x, c4y, @x, @y)
        end

        def flex1
          c1x = @x  + @stack.shift    # dx1
          c1y = @y  + @stack.shift    # dy1
          c2x = c1x + @stack.shift    # dx2
          c2y = c1y + @stack.shift    # dy2
          jpx = c2x + @stack.shift    # dx3
          jpy = c2y + @stack.shift    # dy3
          c3x = jpx + @stack.shift    # dx4
          c3y = jpy + @stack.shift    # dy4
          c4x = c3x + @stack.shift    # dx5
          c4y = c3y + @stack.shift    # dy5

          if (c4x - @x).abs > (c4y - @y).abs
            @x = c4x + @stack.shift
          else
            @y = c4y + @stack.shift
          end

          @path.curve_to(c1x, c1y, c2x, c2y, jpx, jpy)
          @path.curve_to(c3x, c3y, c4x, c4y, @x, @y)
        end

        def endchar
          if @stack.size > 0 && !@have_width
            @width = @stack.shift + nominal_width_x
            @have_width = true
          end

          if @open
            @path.close_path
            @open = false
          end
        end

        def hstemhm
          stem
        end

        def hintmask
          # noop
        end

        def cntrmask
          stem
          @index += (@n_stems + 7) >> 3
        end

        def rmoveto
          if @stack.size > 2 && !@have_width
            @width = @stack.shift + nominal_width_x
            @have_width = true
          end

          @y += @stack.pop
          @x += @stack.pop
          add_contour(@x, @y)
        end

        def hmoveto
          if @stack.size > 1 && !@have_width
            @width = @stack.shift + nominal_width_x;
            @have_width = true
          end

          @x += stack.pop
          add_contour(@x, @y)
        end

        def vstemhm
          stem
        end

        def rcurveline
          while @stack.size > 2
            c1x = @x + @stack.shift
            c1y = @y + @stack.shift
            c2x = c1x + @stack.shift
            c2y = c1y + @stack.shift
            @x = c2x + @stack.shift
            @y = c2y + @stack.shift
            @path.curve_to(c1x, c1y, c2x, c2y, @x, @y)
          end

          @x += @stack.shift
          @y += @stack.shift
          @path.line_to(@x, @y)
        end

        def rlinecurve
          while @stack.size > 6
            @x += @stack.shift
            @y += @stack.shift
            @path.line_to(@x, @y)
          end

          c1x = @x + @stack.shift
          c1y = @y + @stack.shift
          c2x = c1x + @stack.shift
          c2y = c1y + @stack.shift
          @x = c2x + @stack.shift
          @y = c2y + @stack.shift

          @path.curve_to(c1x, c1y, c2x, c2y, @x, @y)
        end

        def vvcurveto
          if @stack.size.odd?
            @x += @stack.shift
          end

          until @stack.empty?
            c1x = @x
            c1y = @y + @stack.shift
            c2x = c1x + @stack.shift
            c2y = c1y + @stack.shift
            @x = c2x;
            @y = c2y + @stack.shift
            @path.curve_to(c1x, c1y, c2x, c2y, @x, @y)
          end
        end

        def hhcurveto
          if @stack.size.odd?
            @y += @stack.shift
          end

          until @stack.empty?
            c1x = @x + @stack.shift
            c1y = @y;
            c2x = c1x + @stack.shift
            c2y = c1y + @stack.shift
            @x = c2x + @stack.shift
            @y = c2y;
            @path.curve_to(c1x, c1y, c2x, c2y, @x, @y)
          end
        end

        def shortint
          b1 = 28
          b2 = read_byte
          @stack.push(((b1 << 24) | (b2 << 16)) >> 16)
        end

        def callgsubr
          code_index = @stack.pop + gsubrs_bias
          subr_code = gsubrs[code_index]

          if subr_code
            @frames.push(StringIO.new(subr_code))
          end
        end

        def vhcurveto
          until stack.empty?
            c1x = @x
            c1y = @y + @stack.shift
            c2x = c1x + @stack.shift
            c2y = c1y + stack.shift
            @x = c2x + @stack.shift
            @y = c2y + (@stack.size == 1 ? @stack.shift : 0)
            @path.curve_to(c1x, c1y, c2x, c2y, @x, @y)

            break if stack.empty?

            c1x = @x + @stack.shift
            c1y = @y
            c2x = c1x + @stack.shift
            c2y = c1y + @stack.shift
            @y = c2y + @stack.shift
            @x = c2x + (@stack.size == 1 ? @stack.shift : 0)
            @path.curve_to(c1x, c1y, c2x, c2y, @x, @y)
          end
        end

        def hvcurveto
          until @stack.empty?
            c1x = @x + @stack.shift
            c1y = @y
            c2x = c1x + @stack.shift
            c2y = c1y + @stack.shift
            @y = c2y + @stack.shift
            @x = c2x + (@stack.size == 1 ? @stack.shift : 0)
            @path.curve_to(c1x, c1y, c2x, c2y, @x, @y)

            break if @stack.empty?

            c1x = @x
            c1y = @y + @stack.shift
            c2x = c1x + @stack.shift
            c2y = c1y + @stack.shift
            @x = c2x + @stack.shift
            @y = c2y + (@stack.size == 1 ? @stack.shift : 0)
            @path.curve_to(c1x, c1y, c2x, c2y, @x, @y)
          end
        end
      end
    end
  end
end
