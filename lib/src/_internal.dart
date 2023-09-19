import 'package:coroutines/core.dart';

import 'job.dart';

/// ignore all

void thenIgnore(e) {}

void Function(Object? object) logcat = print;
// void Function(Object? object) logcat = _ignorePrint;
void _ignorePrint(Object? object) {}

CoroutineContext newCoroutineContext(
  CoroutineContext parentContext,
  CoroutineContext context,
) {
  parentContext = parentContext - Job.sKey;
  final job = context.get(Job.sKey);
  context = job is CompletableJob ? context : context + Job.job();
  return parentContext + context;
}
