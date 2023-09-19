part of coroutines.deferred;

class DeferredImpl<T> extends AbstractDeferred<T> {
  final Job? _parent;
  final Completer<T> _completer;

  @override
  Completer<T> get completer => _completer;

  @override
  Future<T> get future => completer.future;

  @override
  Job? get parent => _parent;

  DeferredImpl(Job? parent, [Completer<T>? completer])
      : _parent = parent ?? _parentJob(),
        _completer = completer ?? Completer();

  static Job? _parentJob() {
    final context = Zone.current[CoroutineContext.symbol] as CoroutineContext?;
    return context?.get(Job.sKey);
  }
}

class DelegatingDeferred<T> extends AbstractDeferred<T>
    with DelegatingJobMixin {
  final Completer<T> _completer;
  @override
  final CompletableJob jobDelegate;

  DelegatingDeferred(CompletableJob job)
      : jobDelegate = job,
        _completer = Completer.sync() {
    jobDelegate.completer.future.then(
      (value) {
        _completer.complete(value);
      },
      onError: (e, s) {
        _completer.completeError(e, s);
      },
    );
  }

  @override
  Completer<T> get completer => _completer;

  @override
  Future<T> get future => _completer.future;
}
