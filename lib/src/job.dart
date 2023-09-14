library coroutines.job;

import 'dart:async';

import 'package:coroutines/core.dart';
import 'package:coroutines/coroutine_scope.dart';

part 'job_support.dart';

abstract class Job extends CoroutineContextElement {
  static final sKey = CoroutineContextKey<Job>();

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
