import 'dart:async';

import '_internal.dart';
import 'core/coroutine_context.dart';
import 'coroutine_stack_trace.dart';
import 'coroutine_start.dart';
import 'coroutine_zone.dart';
import 'deferred.dart';
import 'job.dart';

Job launch(
  FutureOr Function() computation, {
  CoroutineContext context = CoroutineContext.empty,
  CoroutineStart start = CoroutineStart.sync,
  Duration duration = Duration.zero,
}) {
  context += CoroutineStackTrace();
  final parentZone = Zone.current;
  final parentContext = parentZone.checkCoroutine();
  context = newCoroutineContext(parentContext, context);
  final zone = CoroutineZone(context);
  final job = zone.checkCoroutineJob();

  callback() {
    logcat("launch complete start");
    final value = computation();
    if (value is Future) {
      value.then((value) {
        logcat("launch complete async $value");
        job.completer.complete(value);
      });
    } else {
      logcat("launch complete sync $value");
      job.completer.complete(value);
    }
  }

  zone._startCoroutine(callback, start: start, duration: duration);

  return job;
}

Deferred<T> defer<T>(
  FutureOr<T> Function() computation, {
  CoroutineContext context = CoroutineContext.empty,
  CoroutineStart start = CoroutineStart.async,
  Duration duration = Duration.zero,
}) {
  context += CoroutineStackTrace();
  final parentZone = Zone.current;
  final parentContext = parentZone.checkCoroutine();
  Job? job = context.get(Job.sKey);
  if (job == null) {
    job = Deferred<T>(parentZone.coroutineJob);
  } else if (job is Deferred<T>) {
  } else if (job is CompletableJob) {
    job = Deferred<T>.delegate(job);
  }
  if (job is! Deferred<T>) {
    throw StateError('In defer, Job must be Deferred');
  }

  final deferred = job;
  context = newCoroutineContext(parentContext, context + deferred);
  final zone = CoroutineZone(context);

  callback() {
    logcat("defer complete start");
    final value = computation();
    if (value is Future<T>) {
      value.then((value) {
        logcat("defer complete async $value");
      });
    } else {
      logcat("defer complete sync $value");
      deferred.completer.complete(value);
    }
  }

  zone._startCoroutine(callback, start: start, duration: duration);

  return deferred;
}

extension on Zone {
  void _startCoroutine(
    void Function() callback, {
    CoroutineStart start = CoroutineStart.async,
    Duration duration = Duration.zero,
  }) {
    if (duration != Duration.zero || start == CoroutineStart.async) {
      createTimer(duration, callback);
    } else if (start == CoroutineStart.micro) {
      scheduleMicrotask(callback);
    } else {
      runGuarded(callback);
    }
  }
}
