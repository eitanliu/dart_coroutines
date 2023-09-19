part of coroutines.zone;

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
  CoroutineContext get coroutineContext => coroutineZone.coroutineContext!;

  @override
  late Zone coroutineZone = CoroutineZone(_coroutineContext);
}

extension CoroutineScopeExt on CoroutineScope {
  // @pragma('dart2js:tryInline')
  // @pragma("vm:prefer-inline")
  Job launch(
    FutureOr Function() computation, {
    CoroutineContext context = CoroutineContext.empty,
  }) {
    final parentContext = coroutineContext;
    context = newCoroutineContext(parentContext, context);
    final scope = CoroutineScope(context);
    final zone = scope.coroutineZone;
    final job = scope.job;
    // zone.createTimer(Duration.zero, () {
    zone.runGuarded(() {
      try {
        job.completer.complete(computation());
      } catch (e, s) {
        job.completer.completeError(e, s);
      }
    });
    return job;
    return coroutineZone.createTimer(Duration.zero, computation) as Job;
  }

  CompletableJob get job => coroutineContext.get(Job.sKey) as CompletableJob;
}
