import 'dart:async';

import '_internal.dart';
import 'core/coroutine_context.dart';
import 'coroutine_stack_trace.dart';
import 'coroutine_zone.dart';
import 'deferred.dart';
import 'job.dart';

Job launch(
  FutureOr Function() computation, {
  CoroutineContext context = CoroutineContext.empty,
}) {
  context += CoroutineStackTrace();
  final parentZone = Zone.current;
  final parentContext = parentZone.checkCoroutine();
  context = newCoroutineContext(parentContext, context);
  final zone = CoroutineZone(context);
  final job = zone.checkCoroutineJob();
  // zone.createTimer(Duration.zero, () {
  logcat("launch complete");
  zone.runGuarded(() async {
    try {
      logcat("launch complete start");
      final result = await computation();
      job.completer.complete(result);
      logcat("launch complete end");
    } catch (e, s) {
      logcat("launch completeError");
      // if(!job.completer.isCompleted)
      job.completer.completeError(e, s);
    }
  });
  return job;
}

Deferred<T> defer<T>(
  FutureOr<T> Function() computation, {
  CoroutineContext context = CoroutineContext.empty,
}) {
  context += CoroutineStackTrace();
  final parentZone = Zone.current;
  final parentContext = parentZone.checkCoroutine();
  Job? job = context.get(Job.sKey);
  if (job == null) {
    job = Deferred<T>(parentZone.coroutineJob);
  } else if (job is CompletableJob) {
    job = Deferred<T>.delegate(job);
  }
  if (job is! Deferred<T>) {
    throw StateError('In defer, Job must be Deferred');
  }
  final deferred = job;
  context = newCoroutineContext(parentContext, context + deferred);

  final zone = CoroutineZone(context);
  zone.scheduleMicrotask(() {
    try {
      logcat("defer complete start");
      deferred.completer.complete(computation());
      logcat("defer complete end");
    } catch (e, s) {
      logcat("defer completeError");
      // if(!deferred.completer.isCompleted)
      deferred.completer.completeError(e, s);
    }
  });
  return deferred;
}
