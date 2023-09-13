import 'dart:async';

import 'job.dart';

abstract class Deferred<T> extends Job implements Future<T> {
  abstract Future<T> future;

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
  Future join() => future;
}
