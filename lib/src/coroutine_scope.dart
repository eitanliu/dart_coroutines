library coroutines.scope;

import 'dart:async';

import 'package:coroutines/core.dart';

part 'coroutine_scope_impl.dart';

abstract class CoroutineScope {
  // Zone get coroutineZone;

  CoroutineContext get coroutineContext;
}
