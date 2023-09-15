part of coroutines.scope;

Zone _createCoroutineZone(CoroutineScope scope) {
  final spec = _createCoroutineZoneSpec(scope);
  final values = _createCoroutineZoneValues(scope);
  return Zone.current.fork(specification: spec, zoneValues: values);
}

Map<Object?, Object?> _createCoroutineZoneValues(CoroutineScope scope) {
  final context = scope.coroutineContext;
  return {
    CoroutineContext.symbol: context,
  };
}

ZoneSpecification _createCoroutineZoneSpec(CoroutineScope scope) {
  return ZoneSpecification(
    createTimer: _createTimerHandler,
    registerCallback: _registerCallbackHandler,
  );
}

/// [self] 创建函数的 Zone
/// [parent] 上级 Zone 代理
/// [zone] 当前所在的 Zone
Timer _createTimerHandler(Zone self, ZoneDelegate parent, Zone zone,
    Duration duration, void Function() f) {
  self.checkCancelled();
  return JobTimer(self, parent, zone, duration, f);
}

ZoneCallback<R> _registerCallbackHandler<R>(
    Zone self, ZoneDelegate parent, Zone zone, R Function() f) {
  return () {
    self.checkCancelled();
    return parent.registerCallback(zone, f)();
  };
}

extension CoroutineZoneExt on Zone {
  CoroutineContext get context => this[CoroutineContext.symbol];

  Job? get contextJob => context.get(Job.sKey);

  void checkCancelled() {
    final job = contextJob;
    if (job == null) return;
    if (job.isCancelled == true) throw job.getCancellationException();
  }
}
