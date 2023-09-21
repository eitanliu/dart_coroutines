library coroutines.zone;

import 'dart:async';

import 'package:coroutines/core.dart';

import '_internal.dart';
import 'coroutine_exception_handler.dart';
import 'coroutine_stack_trace.dart';
import 'job.dart';

Job coroutineZone(FutureOr Function() computation) {
  final zone = CoroutineZone(CoroutineContext.empty);
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

Job supervisorZone(FutureOr Function() computation) {
  final zone = SupervisorZone(CoroutineContext.empty);
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

// ignore: non_constant_identifier_names
Zone CoroutineZone(CoroutineContext context) {
  final job = context.get(Job.sKey);
  context = job is CompletableJob ? context : context + Job.job();
  return _createCoroutineZone(context);
}

// ignore: non_constant_identifier_names
Zone SupervisorZone(CoroutineContext context) {
  final job = context.get(Job.sKey);
  context = job is CompletableJob ? context : context + Job.supervisor();
  return _createCoroutineZone(context);
}

Zone _createCoroutineZone(CoroutineContext context) {
  final spec = _createCoroutineZoneSpec(context);
  final values = _createCoroutineZoneValues(context);
  return Zone.current.fork(specification: spec, zoneValues: values);
}

Map<Object?, Object?> _createCoroutineZoneValues(CoroutineContext context) {
  final stackTrace = context.get(CoroutineStackTrace.sKey);
  return {
    CoroutineContext.symbol: context,
    if (stackTrace != null) CoroutineStackTrace.sKey: stackTrace,
  };
}

ZoneSpecification _createCoroutineZoneSpec(CoroutineContext context) {
  return ZoneSpecification(
    handleUncaughtError: _handleUncaughtError,
    run: _run,
    registerCallback: _registerCallbackHandler,
    // scheduleMicrotask: _scheduleMicrotask,
    // createTimer: _createTimerHandler,
  );
}

/// [self] 自身所在的 Zone
/// [parent] 上级 Zone 代理相当于 [Zone.current]
/// [zone] 待处里函数的 Zone
void _handleUncaughtError(Zone self, ZoneDelegate parent, Zone zone,
    Object error, StackTrace stackTrace) {
  logcat(
    "UncaughtErrorZone curr ${Zone.current.zoneName}, "
    "${Zone.current.coroutineJob?.isCompleted}",
  );
  logcat(
    "UncaughtErrorZone self ${self.zoneName}, "
    "${self.coroutineJob?.isCompleted}",
  );
  logcat(
    "UncaughtErrorZone zone ${zone.zoneName}, "
    "${zone.coroutineJob?.isCompleted}",
  );
  final job = self.checkCoroutineJob();
  final handler = zone.coroutineContext?.get(CoroutineExceptionHandler.sKey);

  forEachZone(zone: self, (zone) {
    final treeJob = zone.coroutineJob;
    logcat(
      "UncaughtErrorJob Tree ${zone.zoneName}, ${treeJob?.isCompleted}",
    );
  });
  if (error is CancellationException) {
    final cancelled = job.childCancelled(error);
    logcat("UncaughtErrorJob canceled $cancelled ${job.isCompleted}");
    if (cancelled) {
      logcat("Cancellation Trace ${error.stackTrace}");
      parent.handleUncaughtError(zone, error, stackTrace);
    } else {
      // logcat("err $error ${error.hashCode}");
      logcat("Cancellation Trace ${error.stackTrace}");
      // parent.handleUncaughtError(zone, error, stackTrace);
    }
  } else if (handler != null) {
    handler.handleUncaughtError(self, parent, zone, error, stackTrace);
  } else {
    // logcat("err $error ${error.hashCode}");
    // logcat("$stackTrace");
    parent.handleUncaughtError(zone, error, stackTrace);
  }
}

R _run<R>(Zone self, ZoneDelegate parent, Zone zone, R Function() f) {
  zone.ensureActive('run');
  return parent.run(zone, f);
}

ZoneCallback<R> _registerCallbackHandler<R>(
    Zone self, ZoneDelegate parent, Zone zone, R Function() f) {
  nf() {
    zone.ensureActive('callback');

    final result = f();
    return result;
  }

  return parent.registerCallback(zone, nf);
}

void _scheduleMicrotask(
    Zone self, ZoneDelegate parent, Zone zone, void Function() f) {
  nf() {
    self.ensureActive();
    logcat("_scheduleMicrotask run start ${nf.hashCode}");
    f();
    logcat("_scheduleMicrotask run end ${nf.hashCode}");
  }

  logcat("_scheduleMicrotask new ${nf.hashCode}, old ${f.hashCode}");

  parent.scheduleMicrotask(zone, nf);
}

Timer _createTimerHandler(Zone self, ZoneDelegate parent, Zone zone,
    Duration duration, void Function() f) {
  self.ensureActive();
  return JobTimer(self, parent, zone, duration, f);
}
