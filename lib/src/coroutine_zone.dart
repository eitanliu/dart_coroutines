library coroutines.zone;

import 'dart:async';

import 'package:coroutines/core.dart';

import '_internal.dart';
import 'coroutine_exception_handler.dart';
import 'job.dart';

part 'coroutine_scope.dart';
part 'coroutine_scope_impl.dart';

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
  return {
    CoroutineContext.symbol: context,
  };
}

ZoneSpecification _createCoroutineZoneSpec(CoroutineContext context) {
  return ZoneSpecification(
    handleUncaughtError: _handleUncaughtError,
    registerCallback: _registerCallbackHandler,
    // scheduleMicrotask: _scheduleMicrotask,
    // createTimer: _createTimerHandler,
  );
}

/// [self] 创建函数的 Zone
/// [parent] 上级 Zone 代理
/// [zone] 当前所在的 Zone
void _handleUncaughtError(Zone self, ZoneDelegate parent, Zone zone,
    Object error, StackTrace stackTrace) {
  logcat("UncaughtErrorCurr ${Zone.current}${Zone.current.hashCode}");
  logcat("UncaughtErrorZone $zone${zone.hashCode}");
  final job = zone.coroutineJob;
  if (job == null) return parent.handleUncaughtError(zone, error, stackTrace);
  // TODO: UncaughtErrorElement
  final handler = zone.coroutineContext?.get(CoroutineExceptionHandler.sKey);
  if (handler != null) {
    try {
      handler.handleUncaughtError(self, parent, zone, error, stackTrace);
    } on CancellationException {
      logcat("err $error, $stackTrace");
      throw error;
    }
  } else {
    parent.handleUncaughtError(zone, error, stackTrace);
  }
}

ZoneCallback<R> _registerCallbackHandler<R>(
    Zone self, ZoneDelegate parent, Zone zone, R Function() f) {
  nf() {
    self.ensureActive();
    final context = zone.checkCoroutine();

    return CoroutineZone(context).run(() {
      try {
        final result = f();
        return result;
      } catch (e, s) {
        final zone = Zone.current;
        final job = zone.coroutineJob?.forEachJob((job) => false);
        rethrow;
      }
    });
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

extension CoroutineZoneExt on Zone {
  CoroutineContext? get coroutineContext => this[CoroutineContext.symbol];

  CompletableJob? get coroutineJob =>
      coroutineContext?.get(Job.sKey) as CompletableJob?;

  void ensureActive() {
    final job = coroutineJob;
    if (job == null) return;
    if (job.isCancelled == true) {
      throw job.getCancellationException();
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
}
