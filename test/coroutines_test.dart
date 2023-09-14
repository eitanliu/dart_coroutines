import 'package:coroutines/coroutines.dart';
import 'package:test/test.dart';

void main() {
  group('CoroutineContext tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('EmptyCoroutineContext Test', () {
      final context = CoroutineContext.empty;
      expect(context, same(EmptyCoroutineContext.I));
    });
  });
}
