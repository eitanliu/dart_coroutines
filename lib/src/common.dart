import 'dart:async';

import 'package:coroutines/core.dart';
import 'package:coroutines/coroutines.dart';

import 'job.dart';

Job launch(
  FutureOr Function() computation, {
  CoroutineContext context = CoroutineContext.empty,
}) {
  final parentZone = Zone.current;
  final parentContext = parentZone.checkCoroutine();
  context = _newContext(parentContext, context);
  final zone = CourutineZone(context);
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

CoroutineContext _newContext(
  CoroutineContext parentContext,
  CoroutineContext context,
) {
  parentContext = parentContext - Job.sKey;
  final job = context.get(Job.sKey);
  context = job is CompletableJob ? context : context + Job.job();
  return parentContext + context;
}
