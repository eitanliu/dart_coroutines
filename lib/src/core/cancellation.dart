import 'dart:core';

class CancellationException extends StateError {
  final StackTrace _stackTrace;

  CancellationException([
    super.message = 'Coroutines CancellationException',
    StackTrace? stackTrace,
  ]) : _stackTrace = stackTrace ?? StackTrace.current;

  @override
  StackTrace? get stackTrace => _stackTrace;
}
