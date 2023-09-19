part of coroutines.zone;

abstract class CoroutineScope {
  factory CoroutineScope(CoroutineContext context) {
    return _CoroutineScopeImpl(context);
  }

  CoroutineContext get coroutineContext;

  Zone get coroutineZone;
}
