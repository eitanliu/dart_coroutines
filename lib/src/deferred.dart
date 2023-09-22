library coroutines.deferred;

import 'dart:async';

import 'package:coroutines/core.dart';

import '_internal.dart';
import 'job.dart';

part 'deferred_impl.dart';

abstract class Deferred<T> implements CompletableJob, Future<T> {
  factory Deferred(Job? parent, [Completer<T>? completer]) =>
      DeferredImpl<T>(parent, completer);

  factory Deferred.delegate(CompletableJob job) => DelegatingDeferred(job);

  factory Deferred.context(CoroutineContext context, [Zone? zone]) {
    Job? job = context.get(Job.sKey);
    if (job == null) {
      zone ??= Zone.current;
      job = Deferred<T>(zone.coroutineJob);
    } else if (job is Deferred<T>) {
    } else if (job is CompletableJob) {
      job = Deferred<T>.delegate(job);
    }
    if (job is! Deferred<T>) {
      throw StateError('In defer, Job must be Deferred');
    }

    final deferred = job;
    return deferred;
  }

  Future<T> get future;
}

abstract class AbstractDeferred<T> extends CompletableJob
    implements Deferred<T> {
  @override
  Stream<T> asStream() => future.asStream();

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) =>
      future.catchError(onError, test: test);

  @override
  Future<S> then<S>(FutureOr<S> Function(T) onValue, {Function? onError}) =>
      future.then(onValue, onError: onError);

  @override
  Future<T> whenComplete(FutureOr Function() action) =>
      future.whenComplete(action);

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<void> join() => future.thenIgnore();
}
