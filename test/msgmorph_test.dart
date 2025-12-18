import 'package:flutter_test/flutter_test.dart';
import 'package:msgmorph/msgmorph.dart';

void main() {
  group('MsgMorph', () {
    test('SDK should not be initialized by default', () {
      expect(MsgMorph.isInitialized, false);
    });
  });
}
