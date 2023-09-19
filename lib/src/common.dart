import 'dart:async';

import '_internal.dart';
import 'core/coroutine_context.dart';
import 'coroutine_zone.dart';
import 'deferred.dart';
import 'job.dart';

Job launch(
  FutureOr Function() computation, {
  CoroutineContext context = CoroutineContext.empty,
}) {
  final parentZone = Zone.current;
  final parentContext = parentZone.checkCoroutine();
  context = newCoroutineContext(parentContext, context);
  final zone = CoroutineZone(context);
  final job = zone.checkCoroutineJob();
  // zone.createTimer(Duration.zero, () {
  zone.runGuarded(() {
    try {
      job.completer.complete(computation());
    } catch (e, s) {
      job.completer.completeError(e, s);
    }
  });
  return job;
}

Deferred<T> defer<T>(
  FutureOr<T> Function() computation, {
  CoroutineContext context = CoroutineContext.empty,
}) {
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
  zone.runGuarded(() {
    try {
      deferred.completer.complete(computation());
    } catch (e, s) {
      deferred.completer.completeError(e, s);
    }
  });
  return deferred;
}
