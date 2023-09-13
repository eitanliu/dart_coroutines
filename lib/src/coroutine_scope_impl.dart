part of coroutines.scope;

mixin CoroutineScopeMixin implements CoroutineScope {
  // @override
  final Zone coroutineZone = Zone.current;

  @override
  CoroutineContext get coroutineContext {
    final context = coroutineZone[CoroutineContext.symbol];
    assert(
      context is! CoroutineContext,
      'No find CoroutineContext present in Zone tree.',
    );
    return context;
  }
}

extension CoroutineScopeExt on CoroutineScope {
  void launch<T>(FutureOr<T> Function() computation) {}
}
