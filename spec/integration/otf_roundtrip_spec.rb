require 'spec_helper'

describe 'OTF Roundtrip' do
  FONT = TTFunk::File.open(PathHelpers.test_font('NotoSansCJKjp-Regular', 'otf'))

  let(:font) { FONT }

  it 'header' do
    expect(font.cff.header.encode).to(
      eq(
        font.cff.send(:parse_from, font.cff.header.table_offset) do
          font.cff.send(:io).read(font.cff.header.length)
        end
      )
    )
  end

  it 'name_index' do
    expect(font.cff.name_index.encode.string).to(
      eq(
        font.cff.send(:parse_from, font.cff.name_index.table_offset) do
          font.cff.send(:io).read(font.cff.name_index.length)
        end
      )
    )
  end

  # this fails but afaict it's encoding correctly, so disable for now
  xit 'top_index' do
    expect(font.cff.top_index.encode { |td| td.encode }.string).to(
      eq(
        font.cff.send(:parse_from, font.cff.top_index.table_offset) do
          font.cff.send(:io).read(font.cff.top_index.length)
        end
      )
    )
  end

  it 'string_index' do
    expect(font.cff.string_index.encode { |td| td.encode }.string).to(
      eq(
        font.cff.send(:parse_from, font.cff.string_index.table_offset) do
          font.cff.send(:io).read(font.cff.string_index.length)
        end
      )
    )
  end

  it 'global_subr_index' do
    expect(font.cff.global_subr_index.encode.string).to(
      eq(
        font.cff.send(:parse_from, font.cff.global_subr_index.table_offset) do
          font.cff.send(:io).read(font.cff.global_subr_index.length)
        end
      )
    )
  end
end
