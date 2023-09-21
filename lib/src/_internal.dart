import 'dart:async';

import 'package:coroutines/core.dart';

import 'coroutine_stack_trace.dart';
import 'job.dart';

/// ignore all

void thenIgnoreValue(value) {}

void thenIgnoreError(e, s) {}

void logcat(Object? object) => print(object);
// void logcat(Object? object) => _ignorePrint(object);
void _ignorePrint(Object? object) {}

CoroutineContext newCoroutineContext(
  CoroutineContext parentContext, [
  CoroutineContext context = CoroutineContext.empty,
]) {
  parentContext = parentContext - Job.sKey;
  final job = context.get(Job.sKey);
  context = job is CompletableJob ? context : context + Job.job();
  return parentContext + context;
}

forEachZone(Function(Zone zone) operate, {Zone? zone}) {
  zone ??= Zone.current;
  while (zone != null) {
    operate(zone);
    zone = zone.parent;
  }
}

extension InternalOnFutureExt<T> on Future<T> {
  Future thenIgnore() => then(thenIgnoreValue, onError: thenIgnoreError);
}

extension InternalCoroutineZoneExt on Zone {
  CoroutineContext? get coroutineContext => this[CoroutineContext.symbol];

  CompletableJob? get coroutineJob =>
      coroutineContext?.get(Job.sKey) as CompletableJob?;

  void ensureActive([String action = '']) {
    final job = coroutineJob;
    if (job == null) return;

    if (job.isCancelled) {
      final e = job.getCancellationException();
      forEachZone((zone) {
        final treeJob = zone.coroutineJob;
        logcat(
          "ensureActive $action ${zone.zoneName}, ${treeJob?.isCompleted}, ${job.isCompleted}",
        );
      }, zone: this);
      if(job.childCancelled(e)) {

        // job.completer.completeError(e, checkStackTrace().stackTrace);
        // throw CancellationException(e.message, checkStackTrace().stackTrace);
        handleUncaughtError(e, checkStackTrace().stackTrace);
      }
    }
  }

  CoroutineContext checkCoroutine() {
    final context = coroutineContext;
    assert(context != null, "Must run in CoroutineZone");
    return context!;
  }

  JOB checkCoroutineJob<JOB extends CompletableJob>() {
    final job = coroutineJob;
    assert(job != null, "Must run in CoroutineZone");
    // if(job is! JOB) throw StateError(message)
    return job as JOB;
  }

  CoroutineStackTrace checkStackTrace() {
    final stackTrace = coroutineContext?.get(CoroutineStackTrace.sKey);
    assert(stackTrace != null, "Must run in CoroutineZone");
    return stackTrace!;
  }

  String get zoneName => "$runtimeType-$hashCode";
}
