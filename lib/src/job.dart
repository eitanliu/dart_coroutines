library coroutines.job;

import 'dart:async';

import 'package:coroutines/core.dart';
import 'package:coroutines/coroutine_zone.dart';

import '_internal.dart';

part 'job_delegate.dart';

part 'job_impl.dart';

abstract class Job extends CoroutineContextElement {
  static final sKey = CoroutineContextKey<Job>();

  static CompletableJob job([Job? parent, Completer? completer]) =>
      _JobImpl(parent, completer);

  static CompletableJob supervisor([Job? parent, Completer? completer]) =>
      _SupervisorJobImpl(parent, completer);

  @override
  CoroutineContextKey<Job> get key => sKey;

  Job? get parent;

  bool get isActive;

  bool get isCompleted;

  bool get isCancelled;

  Future<void> join();

  void cancelJob([CancellationException? cause]);

  // @protected
  CancellationException getCancellationException();
}
