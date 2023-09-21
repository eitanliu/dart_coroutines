import 'package:coroutines/core.dart';

class CoroutineStackTrace extends CoroutineContextElement {
  static final sKey = CoroutineContextKey<CoroutineStackTrace>();

  final stackTrace = StackTrace.current;

  @override
  CoroutineContextKey<CoroutineStackTrace> get key => sKey;
}
