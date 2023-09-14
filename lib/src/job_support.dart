part of coroutines.job;

abstract class JobSupport extends Job {
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

class JobImpl extends JobSupport {
  @override
  final Job? parent = Zone.current.contextJob;
}

class JobTimer extends JobSupport implements Timer {
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
  Zone zone;

  @override
  Job? get parent {
    final timer = _timer;
    return timer is Job ? timer as Job : null;
  }

  JobTimer(this.zone, this.delegate, Duration duration, ZoneCallback callback)
      : _duration = duration,
        _callback = callback {
    _timer = _createTimer();
  }

  _createTimer() => delegate.createTimer(zone, _duration, _timerCallback);

  _timerCallback() {
    _callback();
    completer.complete();
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
}
