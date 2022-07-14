import 'package:cyber_jacket/chars.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('extract frame', () {
    const text = 'hello world';
    final columns = stringToColumnsBytes(text);
    print(extractFrame(columns, 0));
  });
}
