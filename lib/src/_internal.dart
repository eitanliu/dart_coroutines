import 'package:coroutines/core.dart';

import 'job.dart';

/// ignore all

void thenIgnore(e) {}

void logcat(Object? object) => print(object);
// void logcat(Object? object) => _ignorePrint(object);
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
