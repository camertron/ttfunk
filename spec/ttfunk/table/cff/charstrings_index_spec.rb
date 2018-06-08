require 'spec_helper'
require 'ttfunk/table/cff'

RSpec.describe TTFunk::Table::Cff do
  let(:font_path) { test_font('NotoSansCJKsc-Thin', :otf) }
  let(:font) { TTFunk::File.open(font_path) }
  let(:charstrings_index) { font.cff.top_index[0].charstrings_index }

  it 'constructs the correct path for a Hiragana character' do
    path = charstrings_index[65_500].path

    expect(path.commands).to eq(
      [
        { type: :move, x: 525, y: 742 },
        { type: :line, x: 488, y: 757 },
        { type: :curve, x1: 482, y1: 741, x2: 474, y2: 726, x: 464, y: 706 },
        { type: :curve, x1: 411, y1: 612, x2: 180, y2: 202, x: 110, y: 5 },
        { type: :line, x: 143, y: -7 },
        { type: :curve, x1: 155, y1: 37, x2: 204, y2: 157, x: 236, y: 216 },
        { type: :curve, x1: 275, y1: 290, x2: 365, y2: 379, x: 455, y: 379 },
        { type: :curve, x1: 508, y1: 379, x2: 538, y2: 350, x: 540, y: 300 },
        { type: :curve, x1: 543, y1: 233, x2: 540, y2: 162, x: 543, y: 102 },
        { type: :curve, x1: 545, y1: 58, x2: 562, y2: -9, x: 662, y: -9 },
        { type: :curve, x1: 794, y1: -9, x2: 867, y2: 97, x: 920, y: 242 },
        { type: :line, x: 893, y: 263 },
        { type: :curve, x1: 870, y1: 176, x2: 797, y2: 21, x: 665, y: 21 },
        { type: :curve, x1: 614, y1: 21, x2: 575, y2: 46, x: 573, y: 104 },
        { type: :curve, x1: 571, y1: 157, x2: 572, y2: 229, x: 570, y: 300 },
        { type: :curve, x1: 568, y1: 371, x2: 519, y2: 410, x: 462, y: 410 },
        { type: :curve, x1: 406, y1: 410, x2: 347, y2: 385, x: 289, y: 324 },
        { type: :curve, x1: 342, y1: 425, x2: 455, y2: 629, x: 494, y: 694 },
        { type: :curve, x1: 505, y1: 715, x2: 518, y2: 733, x: 525, y: 742 },
        { type: :close },
        { type: :move, x: 757, y: 694 },
        { type: :line, x: 731, y: 681 },
        { type: :curve, x1: 756, y1: 644, x2: 803, y2: 564, x: 824, y: 526 },
        { type: :line, x: 853, y: 541 },
        { type: :curve, x1: 831, y1: 578, x2: 781, y2: 660, x: 757, y: 694 },
        { type: :close },
        { type: :move, x: 868, y: 737 },
        { type: :line, x: 843, y: 723 },
        { type: :curve, x1: 869, y1: 688, x2: 916, y2: 613, x: 938, y: 572 },
        { type: :line, x: 967, y: 587 },
        { type: :curve, x1: 942, y1: 629, x2: 893, y2: 704, x: 868, y: 737 },
        { type: :close }
      ]
    )
  end

  it 'constructs the correct path for a Hangul character' do
    path = charstrings_index[64_970].path

    expect(path.commands).to eq(
      [
        { type: :move, x: -720, y: 78 },
        { type: :line, x: -568, y: 78 },
        { type: :line, x: -568, y: 235 },
        { type: :line, x: -756, y: 235 },
        { type: :line, x: -756, y: 205 },
        { type: :line, x: -601, y: 205 },
        { type: :line, x: -601, y: 107 },
        { type: :line, x: -753, y: 107 },
        { type: :line, x: -753, y: -59 },
        { type: :line, x: -725, y: -59 },
        { type: :curve, x1: -686, y1: -59, x2: -633, y2: -59, x: -553, y: -44 },
        { type: :line, x: -557, y: -15 },
        { type: :curve, x1: -630, y1: -28, x2: -683, y2: -29, x: -720, y: -29 },
        { type: :close },
        { type: :move, x: -546, y: 205 },
        { type: :line, x: -395, y: 205 },
        { type: :line, x: -395, y: -65 },
        { type: :line, x: -362, y: -65 },
        { type: :line, x: -362, y: 235 },
        { type: :line, x: -546, y: 235 },
        { type: :close },
        { type: :move, x: -229, y: -39 },
        { type: :curve, x1: -270, y1: -39, x2: -295, y2: -5, x: -295, y: 42 },
        { type: :curve, x1: -295, y1: 90, x2: -270, y2: 123, x: -229, y: 123 },
        { type: :curve, x1: -187, y1: 123, x2: -162, y2: 90, x: -162, y: 42 },
        { type: :curve, x1: -162, y1: -5, x2: -187, y2: -39, x: -229, y: -39 },
        { type: :close },
        { type: :move, x: -229, y: 151 },
        { type: :curve, x1: -279, y1: 151, x2: -325, y2: 110, x: -325, y: 42 },
        { type: :curve, x1: -325, y1: -26, x2: -279, y2: -66, x: -229, y: -66 },
        { type: :curve, x1: -178, y1: -66, x2: -132, y2: -26, x: -132, y: 42 },
        { type: :curve, x1: -132, y1: 110, x2: -178, y2: 151, x: -229, y: 151 },
        { type: :close },
        { type: :move, x: -213, y: 206 },
        { type: :line, x: -213, y: 249 },
        { type: :line, x: -246, y: 249 },
        { type: :line, x: -246, y: 206 },
        { type: :line, x: -332, y: 206 },
        { type: :line, x: -332, y: 176 },
        { type: :line, x: -127, y: 176 },
        { type: :line, x: -127, y: 206 },
        { type: :close }
      ]
    )
  end

  it 'constructs the correct path for a complex Han character' do
    path = charstrings_index[28_487].path

    expect(path.commands).to eq(
      [
        { type: :move, x: 132, y: 641 },
        { type: :line, x: 871, y: 641 },
        { type: :line, x: 871, y: 531 },
        { type: :line, x: 900, y: 531 },
        { type: :line, x: 900, y: 670 },
        { type: :line, x: 508, y: 670 },
        { type: :line, x: 508, y: 739 },
        { type: :line, x: 832, y: 739 },
        { type: :line, x: 832, y: 768 },
        { type: :line, x: 508, y: 768 },
        { type: :line, x: 508, y: 831 },
        { type: :line, x: 479, y: 831 },
        { type: :line, x: 479, y: 670 },
        { type: :line, x: 103, y: 670 },
        { type: :line, x: 103, y: 531 },
        { type: :line, x: 132, y: 531 },
        { type: :close },
        { type: :move, x: 654, y: 505 },
        { type: :curve, x1: 725, y1: 474, x2: 809, y2: 427, x: 853, y: 393 },
        { type: :line, x: 873, y: 417 },
        { type: :curve, x1: 829, y1: 452, x2: 744, y2: 497, x: 674, y: 525 },
        { type: :close },
        { type: :move, x: 305, y: 528 },
        { type: :curve, x1: 258, y1: 481, x2: 183, y2: 438, x: 113, y: 408 },
        { type: :curve, x1: 120, y1: 403, x2: 133, y2: 392, x: 137, y: 388 },
        { type: :curve, x1: 205, y1: 419, x2: 284, y2: 469, x: 334, y: 520 },
        { type: :close },
        { type: :move, x: 290, y: 335 },
        { type: :curve, x1: 373, y1: 381, x2: 444, y2: 439, x: 495, y: 505 },
        { type: :curve, x1: 553, y1: 429, x2: 623, y2: 376, x: 703, y: 335 },
        { type: :close },
        { type: :move, x: 270, y: 5 },
        { type: :line, x: 270, y: 87 },
        { type: :line, x: 729, y: 87 },
        { type: :line, x: 729, y: 5 },
        { type: :close },
        { type: :move, x: 270, y: 197 },
        { type: :line, x: 729, y: 197 },
        { type: :line, x: 729, y: 116 },
        { type: :line, x: 270, y: 116 },
        { type: :close },
        { type: :move, x: 729, y: 226 },
        { type: :line, x: 270, y: 226 },
        { type: :line, x: 270, y: 306 },
        { type: :line, x: 729, y: 306 },
        { type: :close },
        { type: :move, x: 805, y: 549 },
        { type: :line, x: 805, y: 578 },
        { type: :line, x: 200, y: 578 },
        { type: :line, x: 200, y: 549 },
        { type: :line, x: 493, y: 549 },
        { type: :curve, x1: 406, y1: 420, x2: 246, y2: 322, x: 53, y: 271 },
        { type: :curve, x1: 60, y1: 266, x2: 68, y2: 255, x: 72, y: 247 },
        { type: :curve, x1: 131, y1: 264, x2: 187, y2: 284, x: 241, y: 310 },
        { type: :line, x: 241, y: -71 },
        { type: :line, x: 270, y: -71 },
        { type: :line, x: 270, y: -24 },
        { type: :line, x: 729, y: -24 },
        { type: :line, x: 729, y: -67 },
        { type: :line, x: 758, y: -67 },
        { type: :line, x: 758, y: 310 },
        { type: :curve, x1: 811, y1: 287, x2: 869, y2: 269, x: 929, y: 253 },
        { type: :curve, x1: 933, y1: 263, x2: 941, y2: 274, x: 949, y: 280 },
        { type: :curve, x1: 765, y1: 326, x2: 616, y2: 387, x: 512, y: 527 },
        { type: :curve, x1: 518, y1: 534, x2: 522, y2: 542, x: 527, y: 549 },
        { type: :close }
      ]
    )
  end
end
