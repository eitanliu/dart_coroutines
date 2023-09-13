import 'dart:core';

class CancellationException extends StateError {
  CancellationException([super.message = 'Coroutines CancellationException']);
}
