library coroutines.job;

import 'dart:async';

import 'package:coroutines/core.dart';
import 'package:coroutines/coroutine_scope.dart';

part 'job_impl.dart';

abstract class Job extends CoroutineContextElement {
  static final sKey = CoroutineContextKey<Job>();

  static CompletableJob job([Job? parent]) => _JobImpl(parent);

  static CompletableJob supervisor([Job? parent]) => _SupervisorJobImpl(parent);

  @override
  CoroutineContextKey<Job> get key => sKey;

  Job? get parent;

  bool get isActive;

  bool get isCompleted;

  bool get isCancelled;

  Future<void> join();

  void cancelJob([CancellationException? cause]);

  CancellationException getCancellationException();
}
