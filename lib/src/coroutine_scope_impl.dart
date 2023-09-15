part of coroutines.scope;

mixin CoroutineCurrentScopeMixin implements CoroutineScope {
  @override
  CoroutineContext get coroutineContext {
    final context = coroutineZone[CoroutineContext.symbol];
    assert(
      context is! CoroutineContext,
      'No find CoroutineContext present in Zone tree.',
    );
    return context;
  }

  @override
  Zone get coroutineZone => Zone.current;
}

class _CoroutineScopeImpl implements CoroutineScope {
  final CoroutineContext _coroutineContext;

  _CoroutineScopeImpl(CoroutineContext context) : _coroutineContext = context;

  @override
  CoroutineContext get coroutineContext => _coroutineContext;

  @override
  late Zone coroutineZone = _createCoroutineZone(this);
}

extension CoroutineScopeExt on CoroutineScope {
  Job launch(
    FutureOr Function() computation, {
    CoroutineContext? context,
  }) {
    return coroutineZone.createTimer(Duration.zero, computation) as Job;
  }

  CompletableJob get job => coroutineContext.get(Job.sKey) as CompletableJob;
}
