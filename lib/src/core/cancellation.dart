import 'dart:core';

class CancellationException extends StateError {
  final StackTrace? _stackTrace;

  CancellationException([
    super.message = 'Coroutines Cancellation Exception',
    StackTrace? stackTrace,
  ]) : _stackTrace = stackTrace;

  @override
  StackTrace? get stackTrace => _stackTrace;
}
