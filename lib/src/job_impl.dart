part of coroutines.job;

abstract class CompletableJob extends Job {
  Completer get completer;

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
  bool get isCancelled => parent?.isCancelled == true ? true : _isCancelled;

  @override
  bool get isCompleted => completer.isCompleted;

  @override
  Future<void> join() {
    return completer.future.then(thenIgnore, onError: thenIgnore);
  }

  bool childCancelled(cause) {
    if (cause is CancellationException) return true;
    return false;
  }

  @override
  CancellationException getCancellationException() {
    return _cancellationException ?? CancellationException("Job was cancelled");
  }

  void forEachJob(bool Function(Job job) action) {
    Job? job = this;
    while (job != null) {
      if (!action(job)) break;
      job = job.parent;
    }
  }
}

class _JobImpl extends CompletableJob {
  final Job? _parent;
  final Completer _completer;

  @override
  Job? get parent => _parent;

  @override
  Completer get completer => _completer;

  _JobImpl(Job? parent, [Completer? completer])
      : _parent = parent ?? _parentJob(),
        _completer = completer ?? Completer.sync();

  static Job? _parentJob() {
    final context = Zone.current[CoroutineContext.symbol] as CoroutineContext?;
    return context?.get(Job.sKey);
  }
}

class _SupervisorJobImpl extends _JobImpl {
  _SupervisorJobImpl(Job? parent, [Completer? completer])
      : super(parent, completer);

  @override
  bool childCancelled(cause) {
    return false;
  }
}

class JobTimer extends Job with DelegatingJobMixin implements Timer {
  /// The duration of the timer.
  final Duration _duration;

  /// The callback to call when the timer fires.
  final ZoneCallback _call;

  /// The timer for the current or most recent countdown.
  ///
  /// This timer is canceled and overwritten every time this [JobTimer]
  /// is reset.
  late Timer _timer;
  ZoneDelegate delegate;
  Zone self;
  Zone zone;
  final CoroutineContext coroutineContext;
  late Zone coroutineZone;

  CompletableJob get coroutineJob => coroutineZone.coroutineJob!;

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
        _call = callback,
        coroutineContext =
            newCoroutineContext(zone.checkCoroutine(), CoroutineContext.empty) {
    coroutineZone = CoroutineZone(coroutineContext);
    logcat("JobTimer new ${_timerCallback.hashCode} old ${_call.hashCode}");
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
        _call = callback,
        coroutineContext =
            newCoroutineContext(zone.checkCoroutine(), CoroutineContext.empty) {
    coroutineZone = CoroutineZone(coroutineContext);
    _timer = _createTimer();
  }

  _createTimer() => delegate.createTimer(zone, _duration, _timerCallback);

  _timerCallback() {
    logcat("JobTimer start ${_timerCallback.hashCode}");
    coroutineZone.runGuarded(_call);
    logcat("JobTimer end ${_timerCallback.hashCode}");
    coroutineJob.completer.complete();
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
  Job get jobDelegate => coroutineJob;
}
