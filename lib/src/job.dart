import 'dart:async';

import 'package:coroutines/core.dart';

abstract class Job extends CoroutineContextElement {
  static final sKey = CoroutineContextKey<Job>();

  @override
  CoroutineContextKey<Job> get key => sKey;

  Job? parent;

  bool get isActive;

  bool get isCompleted;

  bool get isCancelled;

  void cancelJob([CancellationException? cause]);

  Future<void> join();
}
