part of coroutines.job;

mixin DelegatingJobMixin on Job {
  Job get jobDelegate;

  @override
  void cancelJob([CancellationException? cause]) {
    return jobDelegate.cancelJob(cause);
  }

  @override
  CancellationException getCancellationException() {
    return jobDelegate.getCancellationException();
  }

  @override
  bool get isActive => jobDelegate.isActive;

  @override
  bool get isCancelled => jobDelegate.isCancelled;

  @override
  bool get isCompleted => jobDelegate.isCancelled;

  @override
  Future<void> join() {
    return jobDelegate.join();
  }

  @override
  Job? get parent => jobDelegate.parent;
}

class DelegatingJob extends Job with DelegatingJobMixin {
  @override
  final Job jobDelegate;

  DelegatingJob(Job job) : jobDelegate = job;
}
