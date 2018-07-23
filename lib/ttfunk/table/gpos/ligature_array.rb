module TTFunk
  class Table
    class Gpos
      class LigatureArray < TTFunk::SubTable
        attr_reader :mark_class_count, :ligature_attachments

        def initialize(file, offset, mark_class_count)
          @mark_class_count = mark_class_count
          super(file, offset)
        end

        def encode
          EncodedString.new do |result|
            result << [ligature_attachments.count].pack('n')
            ligature_attachments.encode_to(result) do |ligature_attachment|
              [ligature_attachment.placeholder]
            end

            ligature_attachments.each do |ligature_attachment|
              result.resolve_placeholder(ligature_attachment.id, [result.length].pack('n'))
              result << ligature_attachment.encode
            end
          end
        end

        private

        def parse!
          count = read(2, 'n').first

          @ligature_attachments = Sequence.from(io, count, 'n') do |ligature_attachment_offset|
            LigatureAttachTable.new(
              file, table_offset + ligature_attachment_offset, mark_class_count
            )
          end

          @length = 2 + ligature_attachments.length
        end
      end
    end
  end
end
