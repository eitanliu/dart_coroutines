part of coroutines.job;

mixin DelegatingJobMixin on Job {
  Job get _job;

  @override
  void cancelJob([CancellationException? cause]) {
    return _job.cancelJob(cause);
  }

  @override
  CancellationException getCancellationException() {
    return _job.getCancellationException();
  }

  @override
  bool get isActive => _job.isActive;

  @override
  bool get isCancelled => _job.isCancelled;

  @override
  bool get isCompleted => _job.isCancelled;

  @override
  Future<void> join() {
    return _job.join();
  }

  @override
  Job? get parent => _job.parent;
}

class DelegatingJob extends Job with DelegatingJobMixin {
  @override
  final Job _job;

  DelegatingJob(Job job) : _job = job;
}
