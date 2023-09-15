library coroutines.scope;

import 'dart:async';

import 'package:coroutines/core.dart';

import 'job.dart';

part 'coroutine_scope_impl.dart';

part 'coroutine_zone.dart';

abstract class CoroutineScope {
  factory CoroutineScope(CoroutineContext context) {
    final job = context.get(Job.sKey);
    context = job is CompletableJob ? context : context + Job.job();
    return _CoroutineScopeImpl(context);
  }

  CoroutineContext get coroutineContext;

  Zone get coroutineZone;
}
