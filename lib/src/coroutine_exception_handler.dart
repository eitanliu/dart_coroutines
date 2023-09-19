import 'dart:async';

import 'package:coroutines/core.dart';

abstract class CoroutineExceptionHandler extends CoroutineContextElement {
  static final sKey = CoroutineContextKey<CoroutineExceptionHandler>();

  @override
  CoroutineContextKey<CoroutineExceptionHandler> get key => sKey;

  void handleUncaughtError(Zone self, ZoneDelegate parent, Zone zone,
      Object error, StackTrace stackTrace);
}
