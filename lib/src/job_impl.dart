part of coroutines.job;

abstract class CompletableJob extends Job {
  Completer completer = Completer();

  bool _isCancelled = false;
  CancellationException? _cancellationException;

  @override
  void cancelJob([CancellationException? cause]) {
    _cancellationException = cause;
    _isCancelled = true;
    completer.completeError(getCancellationException());
  }

  @override
  bool get isActive => !completer.isCompleted;

  @override
  bool get isCancelled => parent?.isCancelled ?? _isCancelled;

  @override
  bool get isCompleted => completer.isCompleted;

  @override
  Future<void> join() {
    return completer.future.onError((error, stackTrace) => null);
  }

  bool childCancelled(cause) {
    if (cause is CancellationException) return true;
    return false;
  }

  @override
  CancellationException getCancellationException() {
    return _cancellationException ?? CancellationException();
  }
}

class _JobImpl extends CompletableJob {
  final Job? _parent;

  @override
  Job? get parent => _parent;

  _JobImpl(Job? parent) : _parent = parent ?? _parentJob();

  static Job? _parentJob() {
    final context = Zone.current[CoroutineContext.symbol] as CoroutineContext?;
    return context?.get(Job.sKey);
  }
}

class _SupervisorJobImpl extends _JobImpl {
  _SupervisorJobImpl(Job? parent) : super(parent);

  @override
  bool childCancelled(cause) {
    return false;
  }
}

class JobTimer extends Job with DelegatingJobMixin implements Timer {
  /// The duration of the timer.
  final Duration _duration;

  /// The callback to call when the timer fires.
  final ZoneCallback _callback;

  /// The timer for the current or most recent countdown.
  ///
  /// This timer is canceled and overwritten every time this [JobTimer]
  /// is reset.
  late Timer _timer;
  ZoneDelegate delegate;
  Zone self;
  Zone zone;
  CoroutineScope scope;

  @override
  Job? get parent {
    final timer = _timer;
    return timer is Job ? timer as Job : null;
  }

  JobTimer(
    this.self,
    this.delegate,
    this.zone,
    Duration duration,
    ZoneCallback callback,
  )   : _duration = duration,
        _callback = callback,
        scope = CoroutineScope(zone.context + Job.job()) {
    print("job timer create");
    _timer = _createTimer();
  }

  JobTimer.ctx(
    CoroutineContext context,
    this.self,
    this.delegate,
    this.zone,
    Duration duration,
    ZoneCallback callback,
  )   : _duration = duration,
        _callback = callback,
        scope = CoroutineScope(zone.context + context) {
    _timer = _createTimer();
  }

  _createTimer() => delegate.createTimer(zone, _duration, _timerCallback);

  _timerCallback() {
    print("job timer begin");
    scope.coroutineZone.runGuarded(_callback);
    print("job timer end");
    scope.job.completer.complete();
  }

  /// Restarts the timer so that it counts down from its original duration
  /// again.
  ///
  /// This restarts the timer even if it has already fired or has been canceled.
  void reset() {
    _timer.cancel();
    _timer = _createTimer();
  }

  @override
  void cancel() {
    _timer.cancel();
    cancelJob();
  }

  @override
  bool get isActive => _timer.isActive;

  /// The number of durations preceding the most recent timer event on the most
  /// recent countdown.
  ///
  /// Calls to [reset] will also reset the tick so subsequent tick values may
  /// not be strictly larger than previous values.
  @override
  int get tick => _timer.tick;

  @override
  Job get _job => scope.job;
}
