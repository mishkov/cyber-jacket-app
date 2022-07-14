import 'dart:typed_data';

/// each byte of char represents a column of matrix, not a row, be carefull
final Map<String, List<int>> chars = {
  // Russian
  'а': [127, 132, 132, 127],
  'б': [255, 145, 145, 145, 142],
  'в': [255, 145, 145, 110],
  'г': [255, 128, 128, 128],
  'д': [3, 126, 130, 130, 126, 3],
  'е': [255, 145, 145, 129],
  'ё': [255, 145, 145, 129],
  'ж': [239, 16, 255, 16, 239],
  'з': [145, 145, 145, 110],
  'и': [255, 6, 24, 96, 255],
  'й': [63, 130, 140, 144, 63],
  'к': [255, 12, 52, 195],
  'л': [1, 126, 128, 128, 255],
  'м': [255, 96, 24, 96, 255],
  'н': [255, 8, 8, 8, 255],
  'о': [126, 129, 129, 129, 126],
  'п': [255, 128, 128, 128, 255],
  'р': [255, 136, 136, 112],
  'с': [126, 129, 129, 66],
  'т': [128, 128, 255, 128, 128],
  'у': [241, 9, 9, 254],
  'ф': [60, 66, 66, 255, 66, 66, 60],
  'х': [231, 24, 24, 231],
  'ц': [254, 2, 2, 254, 3],
  'ч': [248, 8, 8, 255],
  'ш': [255, 1, 255, 1, 255],
  'щ': [254, 2, 254, 2, 254, 3],
  'ъ': [128, 255, 9, 9, 6],
  'ы': [255, 9, 9, 6, 255],
  'ь': [255, 9, 9, 6],
  'э': [66, 145, 145, 145, 126],
  'ю': [255, 24, 126, 129, 129, 126],
  'я': [99, 148, 152, 255],
  // English
  'a': [127, 132, 132, 127],
  'b': [255, 145, 145, 110],
  'c': [126, 129, 129, 66],
  'd': [255, 129, 129, 126],
  'e': [255, 145, 145, 129],
  'f': [255, 144, 144, 128],
  'g': [126, 129, 137, 137, 78],
  'h': [255, 8, 8, 8, 255],
  'i': [129, 255, 129],
  'j': [134, 129, 129, 254],
  'k': [255, 12, 52, 195],
  'l': [255, 1, 1, 1],
  'm': [255, 96, 24, 96, 255],
  'n': [255, 96, 24, 6, 255],
  'o': [126, 129, 129, 129, 126],
  'p': [255, 136, 136, 112],
  'q': [124, 130, 131, 125],
  'r': [255, 152, 148, 99],
  's': [98, 145, 137, 70],
  't': [128, 128, 255, 128, 128],
  'u': [254, 1, 1, 1, 254],
  'v': [248, 6, 1, 6, 248],
  'w': [224, 28, 3, 60, 60, 3, 28, 224],
  'x': [231, 24, 24, 231],
  'y': [241, 9, 9, 254],
  'z': [131, 133, 137, 145, 161, 193],
  '0': [126, 135, 153, 225, 126],
  '1': [33, 65, 255, 1],
  '2': [99, 133, 137, 113],
  '3': [65, 145, 145, 110],
  '4': [252, 4, 4, 255],
  '5': [241, 145, 145, 142],
  '6': [126, 145, 145, 78],
  '7': [192, 131, 140, 176, 192],
  '8': [110, 145, 145, 110],
  '9': [114, 137, 137, 126],
  '!': [253],
  '.': [1],
  ',': [5, 6],
  '#': [4, 37, 46, 116, 165, 46, 116, 160],
  '@': [126, 129, 157, 165, 165, 125],
  '\$': [36, 82, 255, 74, 36],
  '%': [49, 74, 76, 50, 82, 140],
  '(': [126, 129],
  ')': [129, 126],
  '"': [224, 224],
  '/': [3, 12, 48, 192],
  '❤️': [112, 248, 252, 126, 126, 252, 248, 112],
  '?': [0, 0, 96, 133, 136, 112, 0, 0],
  ' ': [0, 0, 0, 0, 0, 0, 0],
};

List<int> stringToColumnsBytes(String text) {
  text = text.toLowerCase();

  List<int> result = [];

  for (int i = 0; i < text.length; i++) {
    final char = text[i];
    if (chars.containsKey(char)) {
      result.addAll(chars[char]!);
    } else {
      result.addAll(chars['?']!);
    }
    const spaceBetweenChars = 0;
    result.add(spaceBetweenChars);
  }

  return result;
}

Uint8List extractFrame(List<int> textLine, int index) {
  List<int> result = [];

  for (int i = 0; i < 8; i++) {
    int rowByte = 0;
    final bitsToShift = 7 - i;
    final currentBit = 1 << bitsToShift;

    for (int j = 0; j < 8; j++) {
      final textLineIndex =
          index + j < textLine.length ? index + j : index + j - textLine.length;
      final rowBit = textLine[textLineIndex] & currentBit;

      if (rowBit != 0) {
        rowByte |= 1 << (7 - j);
      }
    }

    result.add(rowByte);
  }

  return Uint8List.fromList(result);
}
