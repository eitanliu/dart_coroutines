library coroutines.deferred;

import 'dart:async';

import 'package:coroutines/core.dart';

import '_internal.dart';
import 'job.dart';

part 'deferred_impl.dart';

abstract class Deferred<T> implements CompletableJob, Future<T> {
  factory Deferred(Job? parent, [Completer<T>? completer]) =>
      DeferredImpl<T>(parent, completer);
  Future<T> get future;

  factory Deferred.delegate(CompletableJob job) => DelegatingDeferred(job);
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
  Future<void> join() => future.then(thenIgnore, onError: thenIgnore);
}
