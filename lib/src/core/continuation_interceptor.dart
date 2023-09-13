import 'coroutine_context.dart';

abstract class ContinuationInterceptor extends CoroutineContextElement {
  static final sKey = CoroutineContextKey<ContinuationInterceptor>();

  @override
  CoroutineContextKey<ContinuationInterceptor> get key => sKey;
}
